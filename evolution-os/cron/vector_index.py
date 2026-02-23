#!/usr/bin/env python3
"""
Vector Index Module for Evolution OS
轻量级向量搜索系统，用于语义检索历史记忆
"""

import json
import hashlib
import re
from pathlib import Path
from typing import List, Dict, Tuple, Optional
import numpy as np

class VectorIndex:
    """简单的向量索引系统，使用 TF-IDF 和余弦相似度"""
    
    def __init__(self, index_dir: str = "memory/vector"):
        self.index_dir = Path(index_dir)
        self.index_dir.mkdir(parents=True, exist_ok=True)
        
        self.documents_file = self.index_dir / "documents.json"
        self.vectors_file = self.index_dir / "vectors.npy"
        self.vocab_file = self.index_dir / "vocabulary.json"
        
        self.documents: Dict[str, Dict] = {}
        self.vectors: np.ndarray = np.array([])
        self.vocabulary: Dict[str, int] = {}
        self.idf: Dict[str, float] = {}
        
        self._load_index()
    
    def _load_index(self):
        """加载已有索引"""
        if self.documents_file.exists():
            with open(self.documents_file, 'r', encoding='utf-8') as f:
                self.documents = json.load(f)
        
        if self.vectors_file.exists():
            self.vectors = np.load(self.vectors_file)
        
        if self.vocab_file.exists():
            with open(self.vocab_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.vocabulary = data.get('vocab', {})
                self.idf = data.get('idf', {})
    
    def _save_index(self):
        """保存索引到磁盘"""
        with open(self.documents_file, 'w', encoding='utf-8') as f:
            json.dump(self.documents, f, ensure_ascii=False, indent=2)
        
        if self.vectors.size > 0:
            np.save(self.vectors_file, self.vectors)
        
        with open(self.vocab_file, 'w', encoding='utf-8') as f:
            json.dump({
                'vocab': self.vocabulary,
                'idf': self.idf
            }, f, ensure_ascii=False, indent=2)
    
    def _tokenize(self, text: str) -> List[str]:
        """简单的中文/英文分词"""
        # 转换为小写
        text = text.lower()
        # 提取中文词汇（2-4个字符）
        chinese_words = re.findall(r'[\u4e00-\u9fa5]{2,4}', text)
        # 提取英文单词
        english_words = re.findall(r'[a-z]+', text)
        # 提取数字
        numbers = re.findall(r'\d+', text)
        
        return chinese_words + english_words + numbers
    
    def _build_vocabulary(self, texts: List[str]):
        """构建词汇表"""
        term_freq = {}
        doc_count = len(texts)
        
        for text in texts:
            tokens = set(self._tokenize(text))
            for token in tokens:
                term_freq[token] = term_freq.get(token, 0) + 1
        
        # 构建词汇表和 IDF
        self.vocabulary = {}
        self.idf = {}
        
        for idx, (term, freq) in enumerate(sorted(term_freq.items())):
            self.vocabulary[term] = idx
            # IDF = log(N / df)
            self.idf[term] = np.log(doc_count / (freq + 1)) + 1
    
    def _text_to_vector(self, text: str) -> np.ndarray:
        """将文本转换为向量"""
        tokens = self._tokenize(text)
        vector = np.zeros(len(self.vocabulary))
        
        # 统计词频
        token_counts = {}
        for token in tokens:
            token_counts[token] = token_counts.get(token, 0) + 1
        
        # 计算 TF-IDF
        for token, count in token_counts.items():
            if token in self.vocabulary:
                idx = self.vocabulary[token]
                tf = 1 + np.log(count) if count > 0 else 0
                vector[idx] = tf * self.idf.get(token, 1)
        
        # 归一化
        norm = np.linalg.norm(vector)
        if norm > 0:
            vector = vector / norm
        
        return vector
    
    def add_document(self, doc_id: str, text: str, metadata: Optional[Dict] = None):
        """添加文档到索引"""
        self.documents[doc_id] = {
            'text': text,
            'metadata': metadata or {},
            'length': len(text)
        }
        print(f"[VectorIndex] Added document: {doc_id}")
    
    def build_index(self):
        """构建向量索引"""
        if not self.documents:
            print("[VectorIndex] No documents to index")
            return
        
        print(f"[VectorIndex] Building index for {len(self.documents)} documents...")
        
        # 获取所有文本
        texts = [doc['text'] for doc in self.documents.values()]
        
        # 构建词汇表
        self._build_vocabulary(texts)
        
        # 构建向量矩阵
        vectors = []
        for text in texts:
            vec = self._text_to_vector(text)
            vectors.append(vec)
        
        self.vectors = np.array(vectors)
        
        # 保存索引
        self._save_index()
        print(f"[VectorIndex] Index built: {len(self.vocabulary)} terms, {self.vectors.shape[0]} documents")
    
    def search(self, query: str, top_k: int = 5) -> List[Tuple[str, float, str]]:
        """搜索相似文档"""
        if self.vectors.size == 0 or not self.vocabulary:
            print("[VectorIndex] Index is empty")
            return []
        
        # 转换查询为向量
        query_vec = self._text_to_vector(query)
        
        # 计算余弦相似度
        similarities = np.dot(self.vectors, query_vec)
        
        # 获取 top-k
        top_indices = np.argsort(similarities)[::-1][:top_k]
        
        doc_ids = list(self.documents.keys())
        results = []
        
        for idx in top_indices:
            if similarities[idx] > 0.01:  # 阈值过滤 (降低阈值)
                doc_id = doc_ids[idx]
                doc = self.documents[doc_id]
                results.append((
                    doc_id,
                    float(similarities[idx]),
                    doc['text'][:200] + "..." if len(doc['text']) > 200 else doc['text']
                ))
        
        return results
    
    def search_by_date_range(self, start_date: str, end_date: str) -> List[str]:
        """按日期范围搜索文档ID"""
        results = []
        for doc_id, doc in self.documents.items():
            meta = doc.get('metadata', {})
            date = meta.get('date', '')
            if start_date <= date <= end_date:
                results.append(doc_id)
        return results
    
    def get_stats(self) -> Dict:
        """获取索引统计信息"""
        return {
            'total_documents': len(self.documents),
            'vocabulary_size': len(self.vocabulary),
            'vector_dimensions': self.vectors.shape[1] if self.vectors.size > 0 else 0,
            'index_size_mb': round(
                (self.documents_file.stat().st_size if self.documents_file.exists() else 0 +
                 self.vectors_file.stat().st_size if self.vectors_file.exists() else 0 +
                 self.vocab_file.stat().st_size if self.vocab_file.exists() else 0) / (1024 * 1024),
                2
            )
        }

def index_memory_files():
    """索引所有记忆文件"""
    import glob
    
    index = VectorIndex()
    memory_dir = Path("memory")
    
    if not memory_dir.exists():
        print("[Indexer] Memory directory not found")
        return
    
    # 索引所有日记文件
    for diary_file in sorted(memory_dir.glob("*.md")):
        if diary_file.name == "vector":
            continue
            
        date_str = diary_file.stem
        with open(diary_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 提取关键内容（去掉标题和格式）
        text_only = re.sub(r'#+ ', ' ', content)
        text_only = re.sub(r'\[.*?\]', '', text_only)
        text_only = re.sub(r'\(.*?\)', '', text_only)
        
        doc_id = f"diary:{date_str}"
        index.add_document(doc_id, text_only, {'date': date_str, 'type': 'diary'})
    
    # 索引 AGENTS.md
    if Path("AGENTS.md").exists():
        with open("AGENTS.md", 'r', encoding='utf-8') as f:
            content = f.read()
        index.add_document("agents:identity", content, {'type': 'identity'})
    
    # 索引 MEMORY.md
    if Path("MEMORY.md").exists():
        with open("MEMORY.md", 'r', encoding='utf-8') as f:
            content = f.read()
        index.add_document("memory:core", content, {'type': 'memory'})
    
    # 索引 evolution-log.md
    if Path("evolution-log.md").exists():
        with open("evolution-log.md", 'r', encoding='utf-8') as f:
            content = f.read()
        index.add_document("evolution:log", content, {'type': 'evolution'})
    
    # 构建索引
    index.build_index()
    
    # 打印统计
    stats = index.get_stats()
    print(f"\n[Indexer] Index Statistics:")
    print(f"  - Documents: {stats['total_documents']}")
    print(f"  - Vocabulary: {stats['vocabulary_size']} terms")
    print(f"  - Dimensions: {stats['vector_dimensions']}")
    print(f"  - Size: {stats['index_size_mb']} MB")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python vector_index.py <command> [args]")
        print("Commands:")
        print("  index              - Index all memory files")
        print("  search <query>     - Search for similar content")
        print("  stats              - Show index statistics")
        sys.exit(1)
    
    cmd = sys.argv[1]
    
    if cmd == "index":
        index_memory_files()
    
    elif cmd == "search":
        if len(sys.argv) < 3:
            print("Usage: python vector_index.py search <query>")
            sys.exit(1)
        
        query = sys.argv[2]
        index = VectorIndex()
        
        if index.vectors.size == 0:
            print("[Search] Index is empty, running indexer first...")
            index_memory_files()
            index = VectorIndex()
        
        print(f"\n[Search] Query: '{query}'")
        print("-" * 60)
        
        results = index.search(query, top_k=5)
        
        if not results:
            print("No results found")
        else:
            for i, (doc_id, score, snippet) in enumerate(results, 1):
                print(f"\n{i}. {doc_id} (score: {score:.3f})")
                print(f"   {snippet[:150]}...")
    
    elif cmd == "stats":
        index = VectorIndex()
        stats = index.get_stats()
        print(json.dumps(stats, indent=2))
    
    else:
        print(f"Unknown command: {cmd}")

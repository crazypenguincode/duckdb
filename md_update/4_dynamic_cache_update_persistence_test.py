#!/usr/bin/env python3
"""
第四章 动态缓存更新技术与持久化技术 - 测试脚本
Chapter 4: Dynamic Cache Update and Persistence Technology - Testing Script

本脚本用于测试第四章的核心技术：
1. LRU缓存管理策略
2. TTL时间策略
3. 混合缓存策略
4. 机器学习缓存策略
5. 多种持久化技术
"""

import duckdb
import time
import json
import os
import pickle
import sqlite3
import numpy as np
from typing import Dict, List, Tuple, Any, Optional
from dataclasses import dataclass, asdict
import argparse
import sys
from collections import OrderedDict, defaultdict
from datetime import datetime, timedelta
import threading
import queue
import tempfile

@dataclass
class CacheEntry:
    """缓存条目数据结构"""
    key: str
    value: Any
    created_at: datetime
    last_accessed: datetime
    access_count: int
    size_bytes: int
    priority_score: float

@dataclass
class EvictionMetrics:
    """淘汰策略性能指标"""
    strategy_name: str
    hit_rate: float
    miss_rate: float
    eviction_count: int
    avg_access_time_ms: float
    memory_efficiency: float
    cache_size_mb: float

@dataclass
class PersistenceMetrics:
    """持久化性能指标"""
    strategy_name: str
    write_throughput_mbps: float
    read_throughput_mbps: float
    storage_size_mb: float
    compression_ratio: float
    recovery_time_ms: float
    data_integrity_rate: float

class LRUCache:
    """LRU缓存实现"""
    
    def __init__(self, max_size: int):
        self.max_size = max_size
        self.cache = OrderedDict()
        self.hits = 0
        self.misses = 0
    
    def get(self, key: str) -> Optional[Any]:
        if key in self.cache:
            # 移动到末尾（最近使用）
            value = self.cache.pop(key)
            self.cache[key] = value
            self.hits += 1
            return value
        else:
            self.misses += 1
            return None
    
    def put(self, key: str, value: Any):
        if key in self.cache:
            # 更新现有条目
            self.cache.pop(key)
        elif len(self.cache) >= self.max_size:
            # 淘汰最久未使用的条目
            self.cache.popitem(last=False)
        
        self.cache[key] = value
    
    def get_hit_rate(self) -> float:
        total = self.hits + self.misses
        return self.hits / total if total > 0 else 0.0

class TTLCache:
    """TTL缓存实现"""
    
    def __init__(self, max_size: int, ttl_seconds: int):
        self.max_size = max_size
        self.ttl_seconds = ttl_seconds
        self.cache = {}
        self.timestamps = {}
        self.hits = 0
        self.misses = 0
    
    def _is_expired(self, key: str) -> bool:
        if key not in self.timestamps:
            return True
        return (datetime.now() - self.timestamps[key]).total_seconds() > self.ttl_seconds
    
    def get(self, key: str) -> Optional[Any]:
        if key in self.cache and not self._is_expired(key):
            self.hits += 1
            return self.cache[key]
        else:
            if key in self.cache:
                # 清理过期条目
                del self.cache[key]
                del self.timestamps[key]
            self.misses += 1
            return None
    
    def put(self, key: str, value: Any):
        # 清理过期条目
        self._cleanup_expired()
        
        if len(self.cache) >= self.max_size and key not in self.cache:
            # 随机淘汰一个条目
            oldest_key = next(iter(self.cache))
            del self.cache[oldest_key]
            del self.timestamps[oldest_key]
        
        self.cache[key] = value
        self.timestamps[key] = datetime.now()
    
    def _cleanup_expired(self):
        expired_keys = [k for k in self.cache.keys() if self._is_expired(k)]
        for key in expired_keys:
            del self.cache[key]
            del self.timestamps[key]
    
    def get_hit_rate(self) -> float:
        total = self.hits + self.misses
        return self.hits / total if total > 0 else 0.0

class MLCache:
    """机器学习缓存实现"""
    
    def __init__(self, max_size: int):
        self.max_size = max_size
        self.cache = {}
        self.features = {}  # 存储每个条目的特征
        self.hits = 0
        self.misses = 0
        self.access_history = []
        
        # 简化的ML模型权重
        self.weights = {
            'access_frequency': 0.3,
            'recency': 0.25,
            'size_penalty': -0.15,
            'execution_time': 0.2
        }
    
    def _extract_features(self, key: str, value: Any) -> Dict[str, float]:
        """提取缓存条目特征"""
        current_time = time.time()
        
        # 访问频率
        access_freq = sum(1 for h in self.access_history if h['key'] == key)
        
        # 最近性（时间衰减）
        last_access = max([h['timestamp'] for h in self.access_history if h['key'] == key], default=current_time)
        recency = 1.0 / (1.0 + (current_time - last_access) / 3600)  # 小时衰减
        
        # 大小惩罚
        size_bytes = len(str(value).encode('utf-8'))
        size_penalty = size_bytes / (1024 * 1024)  # MB
        
        # 模拟执行时间
        execution_time = np.random.uniform(0.1, 2.0)
        
        return {
            'access_frequency': access_freq,
            'recency': recency,
            'size_penalty': size_penalty,
            'execution_time': execution_time
        }
    
    def _calculate_priority(self, features: Dict[str, float]) -> float:
        """计算缓存优先级"""
        priority = 0.0
        for feature, value in features.items():
            priority += self.weights.get(feature, 0) * value
        return priority
    
    def get(self, key: str) -> Optional[Any]:
        if key in self.cache:
            # 记录访问
            self.access_history.append({
                'key': key,
                'timestamp': time.time(),
                'action': 'hit'
            })
            self.hits += 1
            return self.cache[key]
        else:
            self.misses += 1
            return None
    
    def put(self, key: str, value: Any):
        features = self._extract_features(key, value)
        
        if len(self.cache) >= self.max_size and key not in self.cache:
            # 使用ML模型选择淘汰条目
            self._evict_by_ml()
        
        self.cache[key] = value
        self.features[key] = features
        
        # 记录访问
        self.access_history.append({
            'key': key,
            'timestamp': time.time(),
            'action': 'put'
        })
        
        # 限制历史记录大小
        if len(self.access_history) > 10000:
            self.access_history = self.access_history[-5000:]
    
    def _evict_by_ml(self):
        """基于ML模型淘汰条目"""
        if not self.cache:
            return
        
        # 计算所有条目的优先级
        priorities = {}
        for key in self.cache.keys():
            if key in self.features:
                priorities[key] = self._calculate_priority(self.features[key])
            else:
                priorities[key] = 0.0
        
        # 淘汰优先级最低的条目
        evict_key = min(priorities.keys(), key=lambda k: priorities[k])
        del self.cache[evict_key]
        if evict_key in self.features:
            del self.features[evict_key]
    
    def get_hit_rate(self) -> float:
        total = self.hits + self.misses
        return self.hits / total if total > 0 else 0.0

class PersistenceStrategy:
    """持久化策略基类"""
    
    def __init__(self, storage_path: str):
        self.storage_path = storage_path
    
    def save(self, key: str, value: Any) -> bool:
        raise NotImplementedError
    
    def load(self, key: str) -> Optional[Any]:
        raise NotImplementedError
    
    def delete(self, key: str) -> bool:
        raise NotImplementedError
    
    def get_storage_size(self) -> float:
        raise NotImplementedError

class MemoryOnlyPersistence(PersistenceStrategy):
    """纯内存持久化策略"""
    
    def __init__(self, storage_path: str):
        super().__init__(storage_path)
        self.memory_store = {}
    
    def save(self, key: str, value: Any) -> bool:
        self.memory_store[key] = value
        return True
    
    def load(self, key: str) -> Optional[Any]:
        return self.memory_store.get(key)
    
    def delete(self, key: str) -> bool:
        if key in self.memory_store:
            del self.memory_store[key]
            return True
        return False
    
    def get_storage_size(self) -> float:
        return len(str(self.memory_store).encode('utf-8')) / (1024 * 1024)

class WALPersistence(PersistenceStrategy):
    """WAL格式持久化策略"""
    
    def __init__(self, storage_path: str):
        super().__init__(storage_path)
        self.wal_file = os.path.join(storage_path, "cache.wal")
        self.index_file = os.path.join(storage_path, "cache.idx")
        self.index = {}
        self._load_index()
    
    def _load_index(self):
        """加载索引文件"""
        if os.path.exists(self.index_file):
            try:
                with open(self.index_file, 'rb') as f:
                    self.index = pickle.load(f)
            except:
                self.index = {}
    
    def _save_index(self):
        """保存索引文件"""
        os.makedirs(os.path.dirname(self.index_file), exist_ok=True)
        with open(self.index_file, 'wb') as f:
            pickle.dump(self.index, f)
    
    def save(self, key: str, value: Any) -> bool:
        try:
            os.makedirs(os.path.dirname(self.wal_file), exist_ok=True)
            
            # 序列化数据
            data = pickle.dumps(value)
            
            # 写入WAL文件
            with open(self.wal_file, 'ab') as f:
                offset = f.tell()
                f.write(len(data).to_bytes(4, 'big'))  # 数据长度
                f.write(data)  # 数据内容
            
            # 更新索引
            self.index[key] = {
                'offset': offset,
                'size': len(data) + 4,
                'timestamp': time.time()
            }
            self._save_index()
            
            return True
        except Exception as e:
            print(f"WAL保存失败: {e}")
            return False
    
    def load(self, key: str) -> Optional[Any]:
        if key not in self.index:
            return None
        
        try:
            entry = self.index[key]
            with open(self.wal_file, 'rb') as f:
                f.seek(entry['offset'])
                data_length = int.from_bytes(f.read(4), 'big')
                data = f.read(data_length)
                return pickle.loads(data)
        except Exception as e:
            print(f"WAL加载失败: {e}")
            return None
    
    def delete(self, key: str) -> bool:
        if key in self.index:
            del self.index[key]
            self._save_index()
            return True
        return False
    
    def get_storage_size(self) -> float:
        total_size = 0
        if os.path.exists(self.wal_file):
            total_size += os.path.getsize(self.wal_file)
        if os.path.exists(self.index_file):
            total_size += os.path.getsize(self.index_file)
        return total_size / (1024 * 1024)

class MaterializedViewPersistence(PersistenceStrategy):
    """物化视图持久化策略"""
    
    def __init__(self, storage_path: str):
        super().__init__(storage_path)
        self.db_file = os.path.join(storage_path, "cache_mv.db")
        self._init_database()
    
    def _init_database(self):
        """初始化数据库"""
        os.makedirs(os.path.dirname(self.db_file), exist_ok=True)
        conn = sqlite3.connect(self.db_file)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS cache_entries (
                key TEXT PRIMARY KEY,
                value BLOB,
                created_at REAL,
                metadata TEXT
            )
        """)
        conn.commit()
        conn.close()
    
    def save(self, key: str, value: Any) -> bool:
        try:
            conn = sqlite3.connect(self.db_file)
            data = pickle.dumps(value)
            metadata = json.dumps({
                'size': len(data),
                'type': type(value).__name__
            })
            
            conn.execute("""
                INSERT OR REPLACE INTO cache_entries 
                (key, value, created_at, metadata) 
                VALUES (?, ?, ?, ?)
            """, (key, data, time.time(), metadata))
            
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            print(f"物化视图保存失败: {e}")
            return False
    
    def load(self, key: str) -> Optional[Any]:
        try:
            conn = sqlite3.connect(self.db_file)
            cursor = conn.execute(
                "SELECT value FROM cache_entries WHERE key = ?", 
                (key,)
            )
            row = cursor.fetchone()
            conn.close()
            
            if row:
                return pickle.loads(row[0])
            return None
        except Exception as e:
            print(f"物化视图加载失败: {e}")
            return None
    
    def delete(self, key: str) -> bool:
        try:
            conn = sqlite3.connect(self.db_file)
            cursor = conn.execute(
                "DELETE FROM cache_entries WHERE key = ?", 
                (key,)
            )
            deleted = cursor.rowcount > 0
            conn.commit()
            conn.close()
            return deleted
        except Exception as e:
            print(f"物化视图删除失败: {e}")
            return False
    
    def get_storage_size(self) -> float:
        if os.path.exists(self.db_file):
            return os.path.getsize(self.db_file) / (1024 * 1024)
        return 0.0

class Chapter4CacheUpdateTester:
    """第四章缓存更新技术测试器"""
    
    def __init__(self, storage_path: str = "/tmp/cache_test"):
        self.storage_path = storage_path
        os.makedirs(storage_path, exist_ok=True)
    
    def test_eviction_strategies(self) -> Dict[str, Any]:
        """测试缓存淘汰策略"""
        print("\n=== 缓存淘汰策略性能测试 ===")
        
        cache_size = 100
        test_data = [(f"key_{i}", f"value_{i}" * 100) for i in range(500)]
        
        strategies = {
            "LRU": LRUCache(cache_size),
            "TTL": TTLCache(cache_size, ttl_seconds=30),
            "ML_BASED": MLCache(cache_size)
        }
        
        results = {}
        
        for strategy_name, cache in strategies.items():
            print(f"测试策略: {strategy_name}")
            
            start_time = time.perf_counter()
            
            # 模拟访问模式
            for i, (key, value) in enumerate(test_data):
                # 写入缓存
                cache.put(key, value)
                
                # 模拟读取（80%概率读取最近的数据）
                if i > 0 and np.random.random() < 0.8:
                    read_key = f"key_{max(0, i - np.random.randint(1, min(i, 50)))}"
                    cache.get(read_key)
            
            total_time = (time.perf_counter() - start_time) * 1000
            
            # 计算性能指标
            hit_rate = cache.get_hit_rate()
            miss_rate = 1.0 - hit_rate
            
            # 估算内存使用
            memory_usage = len(cache.cache) * 0.1  # 简化估算，每个条目0.1MB
            
            metrics = EvictionMetrics(
                strategy_name=strategy_name,
                hit_rate=hit_rate,
                miss_rate=miss_rate,
                eviction_count=max(0, len(test_data) - cache_size),
                avg_access_time_ms=total_time / len(test_data),
                memory_efficiency=hit_rate * 100,
                cache_size_mb=memory_usage
            )
            
            results[strategy_name] = asdict(metrics)
            
            print(f"  命中率: {hit_rate:.3f}")
            print(f"  平均访问时间: {total_time / len(test_data):.3f}ms")
            print(f"  内存使用: {memory_usage:.1f}MB")
        
        return results
    
    def test_persistence_strategies(self) -> Dict[str, Any]:
        """测试持久化策略"""
        print("\n=== 持久化策略性能测试 ===")
        
        strategies = {
            "MEMORY_ONLY": MemoryOnlyPersistence(self.storage_path),
            "WAL_FORMAT": WALPersistence(self.storage_path),
            "MATERIALIZED_VIEW": MaterializedViewPersistence(self.storage_path)
        }
        
        # 测试数据
        test_data = {f"test_key_{i}": f"test_value_{i}" * 1000 for i in range(100)}
        
        results = {}
        
        for strategy_name, persistence in strategies.items():
            print(f"测试持久化策略: {strategy_name}")
            
            # 测试写入性能
            write_start = time.perf_counter()
            write_success = 0
            for key, value in test_data.items():
                if persistence.save(key, value):
                    write_success += 1
            write_time = time.perf_counter() - write_start
            
            # 测试读取性能
            read_start = time.perf_counter()
            read_success = 0
            for key in test_data.keys():
                if persistence.load(key) is not None:
                    read_success += 1
            read_time = time.perf_counter() - read_start
            
            # 计算吞吐量
            data_size_mb = sum(len(str(v).encode('utf-8')) for v in test_data.values()) / (1024 * 1024)
            write_throughput = data_size_mb / write_time if write_time > 0 else 0
            read_throughput = data_size_mb / read_time if read_time > 0 else 0
            
            # 存储大小
            storage_size = persistence.get_storage_size()
            
            # 压缩比
            compression_ratio = data_size_mb / storage_size if storage_size > 0 else 1.0
            
            # 数据完整性
            integrity_rate = read_success / len(test_data) if test_data else 0
            
            metrics = PersistenceMetrics(
                strategy_name=strategy_name,
                write_throughput_mbps=write_throughput,
                read_throughput_mbps=read_throughput,
                storage_size_mb=storage_size,
                compression_ratio=compression_ratio,
                recovery_time_ms=read_time * 1000,
                data_integrity_rate=integrity_rate
            )
            
            results[strategy_name] = asdict(metrics)
            
            print(f"  写入吞吐量: {write_throughput:.2f}MB/s")
            print(f"  读取吞吐量: {read_throughput:.2f}MB/s")
            print(f"  存储大小: {storage_size:.2f}MB")
            print(f"  压缩比: {compression_ratio:.2f}:1")
            print(f"  数据完整性: {integrity_rate:.3f}")
        
        return results
    
    def test_ml_feature_importance(self) -> Dict[str, Any]:
        """测试机器学习特征重要性"""
        print("\n=== 机器学习特征重要性测试 ===")
        
        # 模拟特征数据
        np.random.seed(42)
        n_samples = 1000
        
        features = {
            'execution_time': np.random.uniform(0.1, 10.0, n_samples),
            'access_frequency': np.random.poisson(5, n_samples),
            'query_complexity': np.random.uniform(0, 1, n_samples),
            'temporal_locality': np.random.exponential(0.5, n_samples),
            'result_size': np.random.lognormal(2, 1, n_samples),
            'table_count': np.random.randint(1, 10, n_samples),
            'join_count': np.random.randint(0, 5, n_samples),
            'has_aggregation': np.random.choice([0, 1], n_samples, p=[0.6, 0.4]),
            'has_subquery': np.random.choice([0, 1], n_samples, p=[0.7, 0.3])
        }
        
        # 模拟真实的缓存价值（基于特征的线性组合）
        true_weights = {
            'execution_time': 0.28,
            'access_frequency': 0.22,
            'query_complexity': 0.18,
            'temporal_locality': 0.15,
            'result_size': 0.10,
            'table_count': 0.05,
            'join_count': 0.02
        }
        
        cache_values = np.zeros(n_samples)
        for feature, weight in true_weights.items():
            if feature in features:
                normalized_feature = (features[feature] - np.mean(features[feature])) / np.std(features[feature])
                cache_values += weight * normalized_feature
        
        # 添加噪声
        cache_values += np.random.normal(0, 0.1, n_samples)
        
        # 计算特征重要性（简化的相关性分析）
        feature_importance = {}
        for feature_name, feature_values in features.items():
            correlation = np.corrcoef(feature_values, cache_values)[0, 1]
            feature_importance[feature_name] = abs(correlation)
        
        # 归一化重要性分数
        total_importance = sum(feature_importance.values())
        if total_importance > 0:
            feature_importance = {k: v/total_importance for k, v in feature_importance.items()}
        
        # 排序
        sorted_features = sorted(feature_importance.items(), key=lambda x: x[1], reverse=True)
        
        results = {
            'feature_importance': dict(sorted_features),
            'sample_size': n_samples,
            'correlation_analysis': {
                'avg_correlation': np.mean(list(feature_importance.values())),
                'max_correlation': max(feature_importance.values()),
                'min_correlation': min(feature_importance.values())
            }
        }
        
        print("特征重要性排序:")
        for i, (feature, importance) in enumerate(sorted_features, 1):
            print(f"  {i}. {feature}: {importance:.3f}")
        
        return results
    
    def test_hybrid_strategy_performance(self) -> Dict[str, Any]:
        """测试混合策略性能"""
        print("\n=== 混合策略性能测试 ===")
        
        # 创建混合缓存（结合LRU和TTL）
        lru_cache = LRUCache(50)
        ttl_cache = TTLCache(50, 60)
        
        test_queries = [f"SELECT * FROM table_{i % 10} WHERE id = {i}" for i in range(200)]
        
        results = {
            'lru_performance': {},
            'ttl_performance': {},
            'hybrid_performance': {}
        }
        
        # 测试LRU性能
        start_time = time.perf_counter()
        for i, query in enumerate(test_queries):
            cached_result = lru_cache.get(query)
            if cached_result is None:
                # 模拟查询执行
                time.sleep(0.001)
                result = f"result_for_query_{i}"
                lru_cache.put(query, result)
        lru_time = time.perf_counter() - start_time
        
        results['lru_performance'] = {
            'total_time_ms': lru_time * 1000,
            'hit_rate': lru_cache.get_hit_rate(),
            'avg_query_time_ms': (lru_time * 1000) / len(test_queries)
        }
        
        # 测试TTL性能
        start_time = time.perf_counter()
        for i, query in enumerate(test_queries):
            cached_result = ttl_cache.get(query)
            if cached_result is None:
                # 模拟查询执行
                time.sleep(0.001)
                result = f"result_for_query_{i}"
                ttl_cache.put(query, result)
        ttl_time = time.perf_counter() - start_time
        
        results['ttl_performance'] = {
            'total_time_ms': ttl_time * 1000,
            'hit_rate': ttl_cache.get_hit_rate(),
            'avg_query_time_ms': (ttl_time * 1000) / len(test_queries)
        }
        
        # 模拟混合策略（简化实现）
        hybrid_hits = 0
        hybrid_misses = 0
        start_time = time.perf_counter()
        
        for i, query in enumerate(test_queries):
            # 先检查LRU缓存
            lru_result = lru_cache.get(query)
            if lru_result:
                hybrid_hits += 1
                continue
            
            # 再检查TTL缓存
            ttl_result = ttl_cache.get(query)
            if ttl_result:
                hybrid_hits += 1
                # 将结果添加到LRU缓存
                lru_cache.put(query, ttl_result)
                continue
            
            # 缓存未命中，执行查询
            hybrid_misses += 1
            time.sleep(0.001)
            result = f"result_for_query_{i}"
            lru_cache.put(query, result)
            ttl_cache.put(query, result)
        
        hybrid_time = time.perf_counter() - start_time
        hybrid_hit_rate = hybrid_hits / (hybrid_hits + hybrid_misses) if (hybrid_hits + hybrid_misses) > 0 else 0
        
        results['hybrid_performance'] = {
            'total_time_ms': hybrid_time * 1000,
            'hit_rate': hybrid_hit_rate,
            'avg_query_time_ms': (hybrid_time * 1000) / len(test_queries)
        }
        
        print(f"LRU策略: 命中率 {results['lru_performance']['hit_rate']:.3f}, 平均时间 {results['lru_performance']['avg_query_time_ms']:.2f}ms")
        print(f"TTL策略: 命中率 {results['ttl_performance']['hit_rate']:.3f}, 平均时间 {results['ttl_performance']['avg_query_time_ms']:.2f}ms")
        print(f"混合策略: 命中率 {hybrid_hit_rate:.3f}, 平均时间 {results['hybrid_performance']['avg_query_time_ms']:.2f}ms")
        
        return results
    
    def run_comprehensive_test(self) -> Dict[str, Any]:
        """运行第四章综合测试"""
        print("开始运行第四章动态缓存更新技术与持久化技术综合测试...")
        
        results = {
            "test_timestamp": datetime.now().isoformat(),
            "eviction_strategies": self.test_eviction_strategies(),
            "persistence_strategies": self.test_persistence_strategies(),
            "ml_feature_importance": self.test_ml_feature_importance(),
            "hybrid_strategy_performance": self.test_hybrid_strategy_performance()
        }
        
        return results
    
    def save_results(self, results: Dict[str, Any], filename: str = "chapter4_cache_update_results.json"):
        """保存测试结果"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False, default=str)
        print(f"\n测试结果已保存到: {filename}")
    
    def generate_report(self, results: Dict[str, Any]):
        """生成测试报告"""
        print("\n" + "="*80)
        print("第四章 动态缓存更新技术与持久化技术 - 测试报告")
        print("="*80)
        
        # 淘汰策略测试结果
        print("\n缓存淘汰策略性能:")
        eviction_results = results["eviction_strategies"]
        for strategy, metrics in eviction_results.items():
            print(f"  {strategy}:")
            print(f"    命中率: {metrics['hit_rate']:.3f}")
            print(f"    平均访问时间: {metrics['avg_access_time_ms']:.3f}ms")
            print(f"    内存效率: {metrics['memory_efficiency']:.1f}%")
        
        # 持久化策略测试结果
        print("\n持久化策略性能:")
        persistence_results = results["persistence_strategies"]
        for strategy, metrics in persistence_results.items():
            print(f"  {strategy}:")
            print(f"    写入吞吐量: {metrics['write_throughput_mbps']:.2f}MB/s")
            print(f"    读取吞吐量: {metrics['read_throughput_mbps']:.2f}MB/s")
            print(f"    压缩比: {metrics['compression_ratio']:.2f}:1")
            print(f"    数据完整性: {metrics['data_integrity_rate']:.3f}")
        
        # ML特征重要性
        print("\n机器学习特征重要性:")
        ml_results = results["ml_feature_importance"]
        for feature, importance in list(ml_results['feature_importance'].items())[:5]:
            print(f"  {feature}: {importance:.3f}")
        
        # 混合策略性能
        print("\n混合策略性能对比:")
        hybrid_results = results["hybrid_strategy_performance"]
        for strategy, metrics in hybrid_results.items():
            print(f"  {strategy.replace('_', ' ').title()}:")
            print(f"    命中率: {metrics['hit_rate']:.3f}")
            print(f"    平均查询时间: {metrics['avg_query_time_ms']:.2f}ms")

def main():
    parser = argparse.ArgumentParser(description="第四章动态缓存更新技术与持久化技术测试")
    parser.add_argument("--storage-path", default="/tmp/cache_test", help="存储路径")
    parser.add_argument("--output", default="chapter4_cache_update_results.json", help="输出文件名")
    
    args = parser.parse_args()
    
    # 创建测试器
    tester = Chapter4CacheUpdateTester(args.storage_path)
    
    try:
        # 运行综合测试
        results = tester.run_comprehensive_test()
        
        # 生成报告
        tester.generate_report(results)
        
        # 保存结果
        tester.save_results(results, args.output)
        
        print("\n第四章测试完成!")
        return 0
        
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
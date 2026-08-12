package uz.sqb.abs.pechat.util;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.Cursor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ScanOptions;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;


import java.time.Duration;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

@Component
public class RedisCacheUtil implements CacheUtil {
    private static final Logger logger = LoggerFactory.getLogger(RedisCacheUtil.class);

    private final ValueOperations<String, Object> valueOperations;
    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;

    public RedisCacheUtil(RedisTemplate<String, Object> redisTemplate,
                          ObjectMapper objectMapper) {
        this.redisTemplate = redisTemplate;
        this.valueOperations = redisTemplate.opsForValue();
        this.objectMapper = objectMapper;
    }

    @Override
    public boolean set(Object key, Object o) {
        return executeOperation(() -> {
                    valueOperations.set(String.valueOf(key), o);
                    logger.debug("Cache set: key={}", key);
                    return true;
                }, "Failed to set cache", key,
                false);
    }

    @Override
    public boolean setIfAbsent(Object key, Object o) {
        return executeOperation(() -> {
                    Boolean response = valueOperations.setIfAbsent(String.valueOf(key), o);
                    logger.debug("Cache set: key={}", key);
                    return response != null && response.equals(Boolean.TRUE);
                }, "Failed to set cache", key,
                false);
    }

    @Override
    public boolean setWithDuration(Object key, Object o, Duration ttl) {
        return executeOperation(() -> {
            valueOperations.set(String.valueOf(key), o, ttl);
            logger.debug("Cache set with TTL: key={}, ttl={}s", key, ttl.getSeconds());
            return true;
        }, "Failed to set cache with TTL", key, false);
    }

    @Override
    public boolean set(String keyPrefix, Object key, Object o) {
        String generatedKey = generateKey(keyPrefix, key);
        return set(generatedKey, o);
    }

    @Override
    public boolean setIfAbsent(String keyPrefix, Object key, Object o) {
        String generatedKey = generateKey(keyPrefix, key);
        return setIfAbsent(generatedKey, o);
    }

    @Override
    public boolean setWithDuration(String keyPrefix, Object key, Object o, Duration ttl) {
        String generatedKey = generateKey(keyPrefix, key);
        return setWithDuration(generatedKey, o, ttl);
    }

    @Override
    public boolean setIfAbsentWithDuration(String keyPrefix, Object key, Object o, Duration ttl) {
        String generatedKey = generateKey(keyPrefix, key);
        return executeOperation(() -> {
            Boolean response = valueOperations.setIfAbsent(generatedKey, o, ttl);
            logger.debug("Cache set with TTL: key={}, ttl={}s", key, ttl.getSeconds());
            return response != null && response.equals(Boolean.TRUE);
        }, "Failed to set cache with TTL", key, false);
    }

    @Override
    public Object get(Object key) {
        return executeOperation(() -> {
            Object value = valueOperations.get(String.valueOf(key));
            logger.debug("Cache get: key={}, found={}", key, value != null);
            return value;
        }, "Failed to get from cache", key, null);
    }

    @Override
    public <T> Optional<T> get(Object key, Class<T> clazz) {
        return executeOperation(() -> {
            Object o = valueOperations.get(String.valueOf(key));
            if (o == null) {
                logger.debug("Cache miss: key={}, type={}", key, clazz.getSimpleName());
                return Optional.empty();
            }
            T result = objectMapper.convertValue(o, clazz);
            logger.debug("Cache hit: key={}, type={}", key, clazz.getSimpleName());
            return Optional.of(result);
        }, "Failed to get and convert from cache", key, Optional.empty());
    }

    @Override
    public <T> Optional<T> get(Object key, TypeReference<T> typeReference) {
        return executeOperation(() -> {
            Object o = valueOperations.get(String.valueOf(key));
            if (o == null) {
                logger.debug("Cache miss: key={}, typeRef={}", key, typeReference);
                return Optional.empty();
            }
            T result = objectMapper.convertValue(o, typeReference);
            logger.debug("Cache hit: key={}, typeRef={}", key, typeReference);
            return Optional.of(result);
        }, "Failed to get and convert from cache", key, Optional.empty());
    }

    @Override
    public <T> Optional<T> get(String keyPrefix, Object key, Class<T> clazz) {
        String generatedKey = generateKey(keyPrefix, key);
        return get(generatedKey, clazz);
    }

    @Override
    public <T> Optional<T> get(String keyPrefix, Object key, TypeReference<T> typeReference) {
        String generatedKey = generateKey(keyPrefix, key);
        return get(generatedKey, typeReference);
    }

    @Override
    public boolean evict(Object key) {
        return executeOperation(() -> {
            Boolean result = redisTemplate.delete(String.valueOf(key));
            logger.debug("Cache evict: key={}, success={}", key, result);
            return true;
        }, "Failed to evict from cache", key, false);
    }

    @Override
    public boolean evict(String keyPrefix, Object key) {
        String generatedKey = generateKey(keyPrefix, key);
        return evict(generatedKey);
    }

    /*@Override
    public boolean evictByPattern(String pattern) {
        return executeOperation(() -> {
            Set<String> keys = redisTemplate.keys(pattern);
            if (!keys.isEmpty()) {
                Long count = redisTemplate.delete(keys);
                logger.debug("Cache evict by pattern: pattern={}, keysRemoved={}", pattern, count);
            } else {
                logger.debug("Cache evict by pattern: pattern={}, no keys found", pattern);
            }
            return true;
        }, "Failed to evict from cache by pattern", pattern, false);
    }*/

    @Override
    public boolean evictByPattern(String pattern) {
        return executeOperation(() -> {
            Set<String> keys = new HashSet<>();
            try (Cursor<byte[]> cursor = redisTemplate.getConnectionFactory().getConnection()
                    .scan(ScanOptions.scanOptions().match(pattern).count(100).build())) {
                while (cursor.hasNext()) {
                    keys.add(new String(cursor.next()));
                }
            }
            if (!keys.isEmpty()) {
                redisTemplate.delete(keys);
            }
            return true;
        }, "Failed to evict from cache by pattern", pattern, false);
    }

    @Override
    public <T> Map<String, T> multiGet(List<String> keys, Class<T> clazz) {
        return executeOperation(() -> {
            List<Object> values = valueOperations.multiGet(keys);
            if (values == null) {
                return Collections.emptyMap();
            }

            Map<String, T> result = new java.util.HashMap<>();
            for (int i = 0; i < keys.size(); i++) {
                if (values.get(i) != null) {
                    result.put(keys.get(i), objectMapper.convertValue(values.get(i), clazz));
                }
            }
            logger.debug("Cache multiGet: keyCount={}, hitCount={}", keys.size(), result.size());
            return result;
        }, "Failed to multi-get from cache", keys.size(), Collections.emptyMap());
    }

    @Override
    public <T> boolean multiSet(Map<String, T> keyValueMap) {
        return executeOperation(() -> {
            valueOperations.multiSet(keyValueMap);
            logger.debug("Cache multiSet: keyCount={}", keyValueMap.size());
            return true;
        }, "Failed to multi-set to cache", keyValueMap.size(), false);
    }

    @Override
    public boolean hasKey(Object key) {
        return executeOperation(() -> {
            Boolean exists = redisTemplate.hasKey(String.valueOf(key));
            logger.debug("Cache hasKey: key={}, exists={}", key, exists);
            return Boolean.TRUE.equals(exists);
        }, "Failed to check key existence", key, false);
    }

    @Override
    public boolean hasKey(String keyPrefix, Object key) {
        String generatedKey = generateKey(keyPrefix, key);
        return hasKey(generatedKey);
    }

    @Override
    public boolean expire(Object key, Duration ttl) {
        return executeOperation(() -> {
            Boolean result = redisTemplate.expire(String.valueOf(key), ttl.toMillis(), TimeUnit.MILLISECONDS);
            logger.debug("Cache expire: key={}, ttl={}s, success={}", key, ttl.getSeconds(), result);
            return true;
        }, "Failed to set expiration", key, false);
    }

    @Override
    public boolean expire(String keyPrefix, Object key, Duration ttl) {
        String generatedKey = generateKey(keyPrefix, key);
        return expire(generatedKey, ttl);
    }

    /**
     * Execute a Redis operation with proper error handling and logging
     *
     * @param operation    The operation to execute
     * @param errorMessage Error message prefix
     * @param context      Context information for logging
     * @param <T>          The return type
     * @return The result of the operation or @param onErrorResponse param
     */
    private <T> T executeOperation(Supplier<T> operation, String errorMessage, Object context, T onErrorResponse) {
        try {
            return operation.get();
        } catch (Exception e) {
            logger.error("{}: context={}", errorMessage, context, e);
            return onErrorResponse;
        }
    }
}
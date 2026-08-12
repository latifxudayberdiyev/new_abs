package uz.sqb.abs.pechat.util;


import com.fasterxml.jackson.core.type.TypeReference;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface CacheUtil {
    /**
     * Store a value in the cache.
     *
     * @param key The key
     * @param o   The value to store
     */
    boolean set(Object key, Object o);


    /**
     * Store a value in the cache with a TTL.
     *
     * @param key The key
     * @param o   The value to store
     * @param ttl Time to live
     */
    boolean setWithDuration(Object key, Object o, Duration ttl);

    /**
     * Store a value in the cache using a prefixed key.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     * @param o         The value to store
     */
    boolean set(String keyPrefix, Object key, Object o);


    /**
     * Store a value in the cache using a prefixed key with a TTL.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     * @param o         The value to store
     * @param ttl       Time to live
     */
    boolean setWithDuration(String keyPrefix, Object key, Object o, Duration ttl);

    /**
     * Store a value in the cache using redis command SET NX.
     *
     * @param key The key
     * @param o   The value to store
     */
    boolean setIfAbsent(Object key, Object o);

    /**
     * Store a value in the cache using redis command SET NX and a prefixed key.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     * @param o         The value to store
     */
    boolean setIfAbsent(String keyPrefix, Object key, Object o);


    /**
     * Store a value in the cache using redis command SET NX, a prefixed key and a TTL.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     * @param o         The value to store
     * @param ttl       Time to live
     */
    boolean setIfAbsentWithDuration(String keyPrefix, Object key, Object o, Duration ttl);

    /**
     * Get a value from the cache.
     *
     * @param key The key
     * @return The value or null if not found
     */
    Object get(Object key);

    /**
     * Get a value from the cache and convert it to the specified type.
     *
     * @param key   The key
     * @param clazz The class to convert to
     * @param <T>   The type parameter
     * @return Optional containing the value or empty if not found
     */
    <T> Optional<T> get(Object key, Class<T> clazz);

    /**
     * Get a value from the cache and convert it using the type reference.
     *
     * @param key           The key
     * @param typeReference The type reference to convert to
     * @param <T>           The type parameter
     * @return Optional containing the value or empty if not found
     */
    <T> Optional<T> get(Object key, TypeReference<T> typeReference);

    /**
     * Get a value from the cache using a prefixed key and convert it to the specified type.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     * @param clazz     The class to convert to
     * @param <T>       The type parameter
     * @return Optional containing the value or empty if not found
     */
    <T> Optional<T> get(String keyPrefix, Object key, Class<T> clazz);

    /**
     * Get a value from the cache using a prefixed key and convert it using the type reference.
     *
     * @param keyPrefix     The key prefix
     * @param key           The key
     * @param typeReference The type reference to convert to
     * @param <T>           The type parameter
     * @return Optional containing the value or empty if not found
     */
    <T> Optional<T> get(String keyPrefix, Object key, TypeReference<T> typeReference);

    /**
     * Remove a value from the cache.
     *
     * @param key The key
     */
    boolean evict(Object key);

    /**
     * Remove a value from the cache using a prefixed key.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     */
    boolean evict(String keyPrefix, Object key);

    /**
     * Remove all values matching the pattern.
     *
     * @param pattern The pattern (e.g., "user:*")
     */
    boolean evictByPattern(String pattern);

    /**
     * Get multiple values from the cache at once.
     *
     * @param keys  List of keys to retrieve
     * @param clazz The class to convert to
     * @param <T>   The type parameter
     * @return Map of key-value pairs for found entries
     */
    <T> Map<String, T> multiGet(List<String> keys, Class<T> clazz);

    /**
     * Store multiple values in the cache at once.
     *
     * @param keyValueMap Map of key-value pairs to store
     * @param <T>         The type parameter
     */
    <T> boolean multiSet(Map<String, T> keyValueMap);

    /**
     * Check if a key exists in the cache.
     *
     * @param key The key
     * @return true if the key exists, false otherwise
     */
    boolean hasKey(Object key);

    /**
     * Check if a prefixed key exists in the cache.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     * @return true if the key exists, false otherwise
     */
    boolean hasKey(String keyPrefix, Object key);

    /**
     * Set an expiration time on a key.
     *
     * @param key The key
     * @param ttl Time to live
     */
    boolean expire(Object key, Duration ttl);

    /**
     * Set an expiration time on a prefixed key.
     *
     * @param keyPrefix The key prefix
     * @param key       The key
     * @param ttl       Time to live
     */
    boolean expire(String keyPrefix, Object key, Duration ttl);

    default String generateKey(String keyPrefix, Object key) {
        if (keyPrefix == null || keyPrefix.isEmpty()) {
            return String.valueOf(key);
        }
        return keyPrefix + ":" + key;
    }

}

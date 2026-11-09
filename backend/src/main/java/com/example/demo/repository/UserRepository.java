package com.example.demo.repository;

import com.example.demo.model.User;
import com.example.demo.model.ERole;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends MongoRepository<User, String> {

    Optional<User> findByCin(String cin);
    Optional<User> findByEmail(String email);

    // ⚠️ May throw IncorrectResultSizeDataAccessException if duplicate usernames exist
    Optional<User> findByUsername(String username);

    // ✅ Safe version — always returns the first match even with duplicate usernames
    Optional<User> findFirstByUsername(String username);

    boolean existsByUsername(String username);
    boolean existsByEmail(String email);

    // 🔥 AJOUT IMPORTANT
    List<User> findByRoles_Name(ERole role);
}
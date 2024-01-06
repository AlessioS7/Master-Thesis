package it.polito.authentication.repositories;

import it.polito.authentication.entities.User;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> getUserByUsername(String username);
}

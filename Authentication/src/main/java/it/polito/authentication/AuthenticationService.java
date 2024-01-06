package it.polito.authentication;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import it.polito.authentication.entities.User;
import it.polito.authentication.exceptions.DuplicateUserException;
import it.polito.authentication.exceptions.UserNotFoundException;
import it.polito.authentication.exceptions.WrongCredentialsException;
import it.polito.authentication.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Base64;
import java.util.Date;
import java.util.Optional;

@Service
public class AuthenticationService {
    @Value("${authentication.jwt.key}")
    private String signingKey;

    @Value("${authentication.jwt.expiration}")
    private String JWTExpiration;

    @Value("${authentication.jwt.issuer}")
    private String JWTIssuer;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    private final UserRepository userRepository;

    public AuthenticationService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    private String getJWT(String username) throws NoSuchAlgorithmException, InvalidKeySpecException {
        System.out.println("TEST PRINTLN");

        PrivateKey privateKey = KeyFactory.getInstance("RSA")
                .generatePrivate(new PKCS8EncodedKeySpec(Base64.getDecoder().decode(signingKey)));

        System.out.println(privateKey);

        return Jwts.builder().
                setHeaderParam("kid", "myKeyId").
                setHeaderParam("typ", "JWT").
                setSubject(username).
                setIssuedAt(new Date()).
                setExpiration(new Date(System.currentTimeMillis() + Long.parseLong(JWTExpiration))).
                setIssuer(JWTIssuer).
                signWith(privateKey, SignatureAlgorithm.RS256). // must override the algorithm because not all of them are supported
                        compact();
    }

    public String signup(Credentials credentials) throws DuplicateUserException, NoSuchAlgorithmException, InvalidKeySpecException {
        if (userRepository.getUserByUsername(credentials.getUsername()).isPresent()) {
            throw new DuplicateUserException();
        }

        User u = new User();
        u.setUsername(credentials.getUsername());
        u.setPassword(passwordEncoder.encode(credentials.getPassword()));

        userRepository.save(u);

        return getJWT(u.getUsername());
    }

    public String login(Credentials credentials) throws UserNotFoundException, WrongCredentialsException, NoSuchAlgorithmException, InvalidKeySpecException {
        Optional<User> u = userRepository.getUserByUsername(credentials.getUsername());

        if (u.isEmpty()) {
            throw new UserNotFoundException();
        }

        if (!passwordEncoder.matches(credentials.getPassword(), u.get().getPassword())) {
            throw new WrongCredentialsException();
        }

        return getJWT(credentials.getUsername());
    }
}

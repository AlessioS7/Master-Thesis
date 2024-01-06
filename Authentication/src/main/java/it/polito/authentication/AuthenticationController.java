package it.polito.authentication;

import it.polito.authentication.exceptions.DuplicateUserException;
import it.polito.authentication.exceptions.UserNotFoundException;
import it.polito.authentication.exceptions.WrongCredentialsException;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

@RestController
public class AuthenticationController {
    private final AuthenticationService authService;

    public AuthenticationController(AuthenticationService authService) {
        this.authService = authService;
    }

    @PostMapping("/signup")
    @ResponseStatus(HttpStatus.CREATED)
    public String signup(@RequestBody Credentials credentials) throws WrongCredentialsException, DuplicateUserException, NoSuchAlgorithmException, InvalidKeySpecException {
        if(credentials == null || credentials.getUsername() == null || credentials.getUsername().isBlank() ||
                credentials.getPassword() == null || credentials.getPassword().isEmpty()) {
            throw new WrongCredentialsException();
        }

        return authService.signup(credentials);
    }

    @PostMapping("/login")
    @ResponseStatus(HttpStatus.OK)
    public String login(@RequestBody Credentials credentials) throws UserNotFoundException, WrongCredentialsException, NoSuchAlgorithmException, InvalidKeySpecException {
        if(credentials == null || credentials.getUsername() == null || credentials.getUsername().isBlank() ||
                credentials.getPassword() == null || credentials.getPassword().isEmpty()) {
            throw new WrongCredentialsException();
        }

        return authService.login(credentials);
    }

    @GetMapping("/test")
    public String test() {
        return "TEST";
    }

    @ResponseStatus(HttpStatus.BAD_REQUEST) // 400
    @ExceptionHandler(DuplicateUserException.class)
    public void duplicateUser(DuplicateUserException e) { }

    @ResponseStatus(HttpStatus.UNAUTHORIZED) //401
    @ExceptionHandler(WrongCredentialsException.class)
    public void wrongCredentials(WrongCredentialsException e) { }

    @ResponseStatus(HttpStatus.NOT_FOUND) // 404
    @ExceptionHandler(UserNotFoundException.class)
    public void invalidActivationData(UserNotFoundException e) { }
}

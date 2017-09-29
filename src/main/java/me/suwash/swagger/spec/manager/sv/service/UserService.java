package me.suwash.swagger.spec.manager.sv.service;

import java.util.List;

import me.suwash.swagger.spec.manager.infra.config.ApplicationProperties;
import me.suwash.swagger.spec.manager.infra.util.ValidationUtils;
import me.suwash.swagger.spec.manager.sv.da.UserRepository;
import me.suwash.swagger.spec.manager.sv.domain.User;
import me.suwash.swagger.spec.manager.sv.specification.UserSpec;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private ApplicationProperties props;
    @Autowired
    private UserSpec userSpec;
    @Autowired
    private UserRepository userRepository;

    private User newUser(final String userId, final String email) {
        return new User(userSpec, userRepository, userId, email);
    }

    public List<String> idList() {
        return userRepository.idList();
    }

    public User findById(final String userId) {
        final User criteria = newUser(userId, null);
        userSpec.canFind(criteria);

        final User finded = userRepository.findById(userId);
        ValidationUtils.existData(User.class.getSimpleName(), "id", userId, finded);
        return finded;
    }

    public User addDefaultUser() {
        final String userId = props.getDefaultCommitUser();
        final String email = props.getDefaultCommitEmail();
        return addUser(userId, email);
    }

    public User addUser(final String userId, final String email) {
        final User user = newUser(userId, email);
        user.add();
        return findById(userId);
    }

    public void deleteUser(final String userId) {
        final User user = newUser(userId, null);
        user.delete();
    }

}

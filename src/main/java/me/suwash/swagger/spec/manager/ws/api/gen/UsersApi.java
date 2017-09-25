/**
 * NOTE: This class is auto generated by the swagger code generator program (2.2.3).
 * https://github.com/swagger-api/swagger-codegen
 * Do not edit the class manually.
 */
package me.suwash.swagger.spec.manager.ws.api.gen;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import me.suwash.swagger.spec.manager.ws.model.gen.IdListApiModelGen;
import me.suwash.swagger.spec.manager.ws.model.gen.UsersApiModelGen;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2017-08-08T21:14:16.911+09:00")
@Api(value = "users", description = "Commit User Management API")
public interface UsersApi {

    @ApiOperation(value = "Find all tags", notes = "Returns all users", response = IdListApiModelGen.class, tags = {})
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "successful operation", response = IdListApiModelGen.class),
        @ApiResponse(code = 404, message = "Tag not found", response = Void.class)
    })
    @RequestMapping(value = "/users",
        produces = {
            "application/json"
        },
        method = RequestMethod.GET)
    ResponseEntity<Object> getUsers();

    @ApiOperation(value = "Find user by ID", notes = "Returns a single user", response = UsersApiModelGen.class, tags = {})
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "successful operation", response = UsersApiModelGen.class),
        @ApiResponse(code = 400, message = "Invalid ID supplied", response = Void.class),
        @ApiResponse(code = 404, message = "User not found", response = Void.class)
    })
    @RequestMapping(value = "/users/{userId:.+}",
        produces = {
            "application/json"
        },
        method = RequestMethod.GET)
    ResponseEntity<Object> getUserById(
        @ApiParam(value = "user name for commit") @PathVariable(value = "userId", required = true) final String userId);

    @ApiOperation(value = "Add a user with id", notes = "", response = UsersApiModelGen.class, tags = {})
    @ApiResponses(value = {
        @ApiResponse(code = 405, message = "Invalid input", response = Void.class)
    })
    @RequestMapping(value = "/users/{userId:.+}",
        produces = {
            "application/json"
        },
        consumes = {
            "application/json"
        },
        method = RequestMethod.POST)
    ResponseEntity<Object> addUserWithId(
        @ApiParam(value = "user name for commit") @PathVariable(value = "userId", required = true) final String userId,
        @ApiParam(value = "email address for commit") @RequestParam(value = "email", required = true) final String email);

    @ApiOperation(value = "Deletes a user", notes = "", response = Void.class, tags = {})
    @ApiResponses(value = {
        @ApiResponse(code = 400, message = "Invalid ID supplied", response = Void.class),
        @ApiResponse(code = 404, message = "User not found", response = Void.class)
    })
    @RequestMapping(value = "/users/{userId:.+}",
        method = RequestMethod.DELETE)
    ResponseEntity<Object> deleteUserById(
        @ApiParam(value = "user name for commit") @PathVariable(value = "userId", required = true) final String userId);

}
package me.suwash.swagger.spec.manager.ws;

import static org.springframework.hateoas.mvc.ControllerLinkBuilder.linkTo;
import static org.springframework.hateoas.mvc.ControllerLinkBuilder.methodOn;
import io.swagger.annotations.ApiParam;

import java.util.List;

import me.suwash.swagger.spec.manager.ap.SpecFacade;
import me.suwash.swagger.spec.manager.infra.config.CommitInfo;
import me.suwash.swagger.spec.manager.sv.domain.Spec;
import me.suwash.swagger.spec.manager.ws.gen.SpecsApi;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.hateoas.Identifiable;
import org.springframework.hateoas.Link;
import org.springframework.hateoas.ResourceSupport;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2017-08-08T09:16:20.502+09:00")
@Controller
public class SpecsApiController extends BaseApiController implements SpecsApi {

    @Autowired
    private SpecFacade facade;

    @Override
    public ResponseEntity<Identifiable<Link>> getSpecs(
        @ApiParam(value = "user name for commit") @RequestHeader(value = "x-commit-user", required = false) final String commitUser,
        @ApiParam(value = "email address for commit") @RequestHeader(value = "x-commit-email", required = false) final String commitEmail) {

        final CommitInfo commitInfo = commitInfo(commitUser, commitEmail);
        final List<String> idList = facade.idList(commitInfo);

        final ResourceSupport resource = new ResourceSupport();
        if (idList.isEmpty())
            return new ResponseEntity<Identifiable<Link>>(resource, HttpStatus.NO_CONTENT);

        for (final String curId : idList)
            resource.add(linkTo(methodOn(this.getClass()).getSpecById(commitUser, commitEmail, curId)).withSelfRel());
        return new ResponseEntity<Identifiable<Link>>(resource, HttpStatus.OK);
    }

    @Override
    public ResponseEntity<Object> getSpecById(
        @ApiParam(value = "user name for commit") @RequestHeader(value = "x-commit-user", required = false) final String commitUser,
        @ApiParam(value = "email address for commit") @RequestHeader(value = "x-commit-email", required = false) final String commitEmail,
        @ApiParam(value = "ID of specification to return", required = true) @PathVariable("specId") final String specId) {

        final CommitInfo commitInfo = commitInfo(commitUser, commitEmail);
        final Spec finded = facade.findById(commitInfo, specId);
        return ResponseEntity.ok(finded.getPayload());
    }

    @Override
    public ResponseEntity<Object> addSpecWithId(
        @ApiParam(value = "user name for commit") @RequestHeader(value = "x-commit-user", required = false) final String commitUser,
        @ApiParam(value = "email address for commit") @RequestHeader(value = "x-commit-email", required = false) final String commitEmail,
        @ApiParam(value = "message for commit") @RequestHeader(value = "x-commit-message", required = false) final String commitMessage,
        @ApiParam(value = "ID of specification that needs to be add", required = true) @PathVariable("specId") final String specId,
        @ApiParam(value = "Specification object that needs to be add", required = true) @RequestBody final Object payload) {

        final CommitInfo commitInfo = commitInfo(commitUser, commitEmail, commitMessage);
        final Spec added = facade.add(commitInfo, specId, payload);
        return new ResponseEntity<Object>(added.getPayload(), HttpStatus.CREATED);
    }

    @Override
    public ResponseEntity<Object> updateSpecWithId(
        @ApiParam(value = "user name for commit") @RequestHeader(value = "x-commit-user", required = false) final String commitUser,
        @ApiParam(value = "email address for commit") @RequestHeader(value = "x-commit-email", required = false) final String commitEmail,
        @ApiParam(value = "ID of specification that needs to be update", required = true) @PathVariable("specId") final String specId,
        @ApiParam(value = "Specification object that needs to be update", required = true) @RequestBody final Object payload) {

        final CommitInfo commitInfo = commitInfo(commitUser, commitEmail);
        final Spec updated = facade.update(commitInfo, specId, payload);
        return new ResponseEntity<Object>(updated.getPayload(), HttpStatus.OK);
    }

    @Override
    public ResponseEntity<Void> deleteSpecById(
        @ApiParam(value = "user name for commit") @RequestHeader(value = "x-commit-user", required = false) final String commitUser,
        @ApiParam(value = "email address for commit") @RequestHeader(value = "x-commit-email", required = false) final String commitEmail,
        @ApiParam(value = "ID of specification to delete", required = true) @PathVariable("specId") final String specId) {

        final CommitInfo commitInfo = commitInfo(commitUser, commitEmail);
        facade.delete(commitInfo, specId);
        return new ResponseEntity<Void>(HttpStatus.OK);
    }

}

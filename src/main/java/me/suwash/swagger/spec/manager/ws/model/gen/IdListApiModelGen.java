package me.suwash.swagger.spec.manager.ws.model.gen;

import java.util.List;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;

import com.fasterxml.jackson.annotation.JsonProperty;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2017-08-08T21:14:16.911+09:00")
@AllArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class IdListApiModelGen {
    @JsonProperty("idList")
    protected List<String> idList = null;

}

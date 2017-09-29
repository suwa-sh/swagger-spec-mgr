package me.suwash.swagger.spec.manager.ws.mapper;

import me.suwash.swagger.spec.manager.ap.dto.SpecDto;
import me.suwash.swagger.spec.manager.ws.infra.BaseApiModelMapper;

import org.springframework.http.HttpStatus;

public class SpecsApiModelMapper extends BaseApiModelMapper {
    public SpecsApiModelMapper(final SpecDto dto, final OperationType operation) {
        if (OperationType.READ.equals(operation) && dto.getSpec() == null) {
            this.httpStatus = HttpStatus.NOT_FOUND;
            this.body = newBody(null, dto);
            return;
        }

        if (dto.hasError()) {
            this.httpStatus = HttpStatus.BAD_REQUEST;
            this.body = newBody(null, dto);
            return;
        }

        switch (operation) {
            case CREATE:
                this.httpStatus = HttpStatus.CREATED;
                this.body = dto.getSpec().getPayload();
                break;
            case READ:
            case UPDATE:
                this.httpStatus = HttpStatus.OK;
                this.body = dto.getSpec().getPayload();
                break;
            case DELETE:
            default:
                this.httpStatus = HttpStatus.OK;
                this.body = null;
                break;
        }
    }
}

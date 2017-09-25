package me.suwash.swagger.spec.manager.sv.service;

import static me.suwash.swagger.spec.manager.infra.error.SpecMgrException.array;

import java.util.List;

import me.suwash.swagger.spec.manager.infra.constant.MessageConst;
import me.suwash.swagger.spec.manager.infra.error.SpecMgrException;
import me.suwash.swagger.spec.manager.sv.da.GitBranchRepository;
import me.suwash.swagger.spec.manager.sv.domain.Branch;
import me.suwash.swagger.spec.manager.sv.specification.BranchSpec;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class BranchService {

    @Autowired
    private BranchSpec branchSpec;
    @Autowired
    private GitBranchRepository repository;

    private Branch newBranch(final String branch) {
        return new Branch(branchSpec, repository, branch);
    }

    public List<String> idList() {
        return repository.branchList();
    }

    public Branch findById(final String branch) {
        final Branch criteria = newBranch(branch);
        branchSpec.canFind(criteria);

        if (repository.isExistBranch(branch)) return newBranch(branch);
        throw new SpecMgrException(MessageConst.DATA_NOT_EXIST, array(Branch.class.getSimpleName(), "id", branch));
    }

    public Branch addBranch(final String gitObject, final String branchId) {
        final Branch branch = newBranch(branchId);
        branch.add(gitObject);
        return findById(branchId);
    }

    public Branch renameBranch(final String fromBranch, final String toBranch) {
        final Branch finded = newBranch(fromBranch);
        finded.rename(toBranch);
        return findById(toBranch);
    }

    public void deleteBranch(final String branchId) {
        final Branch finded = newBranch(branchId);
        finded.delete();
    }

    public Branch switchBranch(final String branch) {
        final Branch toBranch = newBranch(branch);

        toBranch.switchBranch();
        return toBranch;
    }

    public Branch mergeBranch(final String from, final String to) {
        final Branch fromBranch = newBranch(from);
        final Branch toBranch = newBranch(to);

        fromBranch.mergeInto(toBranch);
        return toBranch;
    }

}
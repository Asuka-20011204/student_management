package com.example.student.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.example.student.common.Result;
import com.example.student.dto.ScoreInputDTO;
import com.example.student.dto.ScoreQuery;
import com.example.student.entity.Score;
import com.example.student.service.ScoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/scores")
@RequiredArgsConstructor
public class ScoreController {

    private final ScoreService scoreService;

    /** 分页查询 */
    @GetMapping
    public Result<IPage<Score>> list(ScoreQuery query) {
        return Result.ok(scoreService.pageQuery(query));
    }

    /** 录入/修改单条成绩 */
    @PostMapping
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_TEACHER')")
    public Result<Void> save(@RequestBody ScoreInputDTO dto) {
        scoreService.save(dto);
        return Result.ok();
    }

    /** 批量录入成绩 */
    @PostMapping("/batch")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_TEACHER')")
    public Result<Void> batchSave(@RequestBody List<ScoreInputDTO> list) {
        scoreService.batchSave(list);
        return Result.ok();
    }

    /** 删除 */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_TEACHER')")
    public Result<Void> delete(@PathVariable Long id) {
        scoreService.delete(id);
        return Result.ok();
    }

    /** 成绩统计 */
    @GetMapping("/stats")
    public Result<List<Map<String, Object>>> stats(@RequestParam Long classId,
                                                    @RequestParam Long courseId,
                                                    @RequestParam(required = false) String examType) {
        return Result.ok(scoreService.stats(classId, courseId, examType));
    }
}

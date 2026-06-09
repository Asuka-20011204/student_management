package com.example.student.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.student.common.BusinessException;
import com.example.student.dto.ScoreInputDTO;
import com.example.student.dto.ScoreQuery;
import com.example.student.entity.Score;
import com.example.student.mapper.ScoreMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ScoreService {

    private final ScoreMapper scoreMapper;

    /** 分页查询成绩 */
    public IPage<Score> pageQuery(ScoreQuery query) {
        Page<Score> page = new Page<>(query.getPage(), query.getPageSize());
        return scoreMapper.selectPageWithDetails(page,
                query.getStudentName(), query.getClassId(),
                query.getCourseId(), query.getExamType(), query.getStudentId());
    }

    /** 录入/修改成绩 */
    @Transactional
    public void save(ScoreInputDTO dto) {
        // 检查是否已存在（同一学生 + 同一排课 + 同一考试类型）
        Score exist = scoreMapper.selectOne(new LambdaQueryWrapper<Score>()
                .eq(Score::getStudentId, dto.getStudentId())
                .eq(Score::getClassCourseId, dto.getClassCourseId())
                .eq(Score::getExamType, dto.getExamType()));

        if (exist != null) {
            // 更新
            exist.setScore(dto.getScore());
            exist.setRemark(dto.getRemark());
            scoreMapper.updateById(exist);
        } else {
            // 新增
            Score score = new Score();
            score.setStudentId(dto.getStudentId());
            score.setClassCourseId(dto.getClassCourseId());
            score.setScore(dto.getScore());
            score.setExamType(dto.getExamType());
            score.setRemark(dto.getRemark());
            scoreMapper.insert(score);
        }
    }

    /** 批量录入成绩 */
    @Transactional
    public void batchSave(List<ScoreInputDTO> list) {
        for (ScoreInputDTO dto : list) {
            save(dto);
        }
    }

    @Transactional
    public void delete(Long id) {
        scoreMapper.deleteById(id);
    }

    /** 成绩统计 */
    public List<Map<String, Object>> stats(Long classId, Long courseId, String examType) {
        if (classId == null || courseId == null) {
            throw new BusinessException("班级和课程不能为空");
        }
        return scoreMapper.selectScoreStats(classId, courseId, examType);
    }
}

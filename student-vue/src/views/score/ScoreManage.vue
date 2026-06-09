<template>
  <div class="page-container">
    <div class="page-header"><h2>成绩管理</h2><div style="display:flex;gap:8px"><el-button @click="st=!st" :type="st?'warning':'default'">{{ st?'收起统计':'统计' }}</el-button><el-button v-if="canEdit" type="primary" @click="inp()">+ 录入</el-button></div></div>
    <div class="search-bar">
      <el-input v-model="q.studentName" placeholder="姓名" clearable style="width:120px" @keyup.enter="load"/>
      <el-select v-model="q.classId" placeholder="班级" clearable style="width:140px" @change="load"><el-option v-for="c in co" :key="c.id" :label="c.className" :value="c.id"/></el-select>
      <el-select v-model="q.courseId" placeholder="课程" clearable style="width:140px"><el-option v-for="c in cro" :key="c.id" :label="c.courseName" :value="c.id"/></el-select>
      <el-select v-model="q.examType" placeholder="类型" clearable style="width:90px"><el-option label="期中" value="期中"/><el-option label="期末" value="期末"/><el-option label="补考" value="补考"/></el-select>
      <el-button type="primary" @click="load">查询</el-button>
    </div>
    <div v-if="st" class="stats-box">
      <div class="stat-cards"><div class="stat-card"><div class="value">{{ sd.avg||'--' }}</div><div class="label">平均分</div></div><div class="stat-card"><div class="value">{{ sd.max||'--' }}</div><div class="label">最高分</div></div><div class="stat-card"><div class="value">{{ sd.min||'--' }}</div><div class="label">最低分</div></div><div class="stat-card"><div class="value">{{ sd.pr||'--' }}%</div><div class="label">及格率</div></div></div>
      <div ref="cr" style="height:220px"></div>
    </div>
    <el-table :data="rows" stripe v-loading="ld" v-if="!ld && rows.length>0">
      <el-table-column prop="studentNo" label="学号" width="100"/><el-table-column prop="studentName" label="姓名" width="80"/>
      <el-table-column prop="className" label="班级" width="130"/><el-table-column prop="courseName" label="课程" width="130"/>
      <el-table-column prop="semester" label="学期" width="120"/><el-table-column label="类型" width="70"><template #default="{row}"><el-tag :type="row.examType==='期末'?'warning':row.examType==='期中'?'info':'danger'" size="small">{{ row.examType }}</el-tag></template></el-table-column>
      <el-table-column label="分数" width="75"><template #default="{row}"><span :style="{color:row.score<60?'var(--err)':'var(--ok)',fontWeight:700}">{{ row.score }}</span></template></el-table-column>
      <el-table-column prop="remark" label="备注" min-width="100" show-overflow-tooltip/>
      <el-table-column label="" width="75" fixed="right" v-if="canEdit"><template #default="{row}"><el-button size="small" type="danger" link @click="doDel(row.id)">删除</el-button></template></el-table-column>
    </el-table>
    <div v-if="!ld && rows.length===0" class="empty-state"><el-empty description="暂无成绩数据" /></div>
    <el-pagination v-model:current-page="q.page" v-model:page-size="q.pageSize" :total="total" :page-sizes="[10,20,50]" layout="total,prev,pager,next" @change="load" background/>
    <el-dialog v-model="iv" title="录入成绩" width="660px" :close-on-click-modal="false">
      <el-form :inline="true" style="margin-bottom:10px">
        <el-form-item label="班级"><el-select v-model="ifm.cid" style="width:160px" @change="onCc"><el-option v-for="c in co" :key="c.id" :label="c.className" :value="c.id"/></el-select></el-form-item>
        <el-form-item label="排课"><el-select v-model="ifm.ccid" style="width:220px" @change="onStu"><el-option v-for="x in ccop" :key="x.id" :label="`${x.courseName} · ${x.semester}`" :value="x.id"/></el-select></el-form-item>
        <el-form-item label="类型"><el-select v-model="ifm.et" style="width:90px"><el-option label="期中" value="期中"/><el-option label="期末" value="期末"/><el-option label="补考" value="补考"/></el-select></el-form-item>
      </el-form>
      <el-table :data="sr" max-height="320" stripe><el-table-column prop="studentNo" label="学号" width="90"/><el-table-column prop="name" label="姓名" width="75"/><el-table-column label="成绩" min-width="150"><template #default="{row}"><el-input-number v-model="row.score" :min="0" :max="100" :precision="1" size="small" controls-position="right"/></template></el-table-column></el-table>
      <template #footer><el-button @click="iv=false">取消</el-button><el-button type="primary" @click="doSave">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref,reactive,onMounted,onUnmounted,computed,nextTick,watch } from 'vue';import { ElMessage,ElMessageBox } from 'element-plus';import { useAuthStore } from '@/stores';import { getScoreList,batchSaveScores,deleteScore,getScoreStats,getClassList,getCourseList,getClassCoursesByClass,getStudentList } from '@/utils/request';import * as echarts from 'echarts'
const au=useAuthStore();const canEdit=computed(()=>au.isAdmin||au.isTeacher)
const ld=ref(false);const rows=ref([]);const total=ref(0);const co=ref([]);const cro=ref([])
const q=reactive({page:1,pageSize:10,studentName:'',classId:null,courseId:null,examType:''})
const st=ref(false);const sd=reactive({avg:null,max:null,min:null,pr:null});const cr=ref(null);let ch=null
const iv=ref(false);const ccop=ref([]);const sr=ref([]);const ifm=reactive({cid:null,ccid:null,et:'期末'})
onMounted(async()=>{const[a,b]=await Promise.all([getClassList({page:1,pageSize:999}),getCourseList({page:1,pageSize:999})]);co.value=a?.records||[];cro.value=b?.records||[];load()});onUnmounted(()=>ch?.dispose())
async function load(){ld.value=true;try{const r=await getScoreList(q);rows.value=r?.records||[];total.value=r?.total||0}finally{ld.value=false}}
watch(st,async v=>{if(v)await lstat()})
async function lstat(){if(!q.classId||!q.courseId){ElMessage.warning('请选择班级和课程');st.value=false;return}try{const r=await getScoreStats({classId:q.classId,courseId:q.courseId,examType:q.examType||null});const s=r?.[0]||{};Object.assign(sd,{avg:s.avg_score,max:s.max_score,min:s.min_score,pr:s.pass_rate});await nextTick();if(!ch)ch=echarts.init(cr.value);const sc=rows.value.filter(r=>row.score!=null).map(r=>Number(row.score));const b={'0-59':0,'60-69':0,'70-79':0,'80-89':0,'90-100':0};sc.forEach(s=>{if(s<60)b['0-59']++;else if(s<70)b['60-69']++;else if(s<80)b['70-79']++;else if(s<90)b['80-89']++;else b['90-100']++});ch.setOption({tooltip:{trigger:'axis'},xAxis:{type:'category',data:Object.keys(b)},yAxis:{type:'value',name:'人数'},series:[{type:'bar',data:Object.values(b),itemStyle:{borderRadius:[6,6,0,0],color:new echarts.graphic.LinearGradient(0,0,0,1,[{offset:0,color:'#3366cc'},{offset:1,color:'#88aadd'}])},barWidth:'40%'}]},true)}catch{}}
async function inp(){Object.assign(ifm,{cid:null,ccid:null,et:'期末'});ccop.value=[];sr.value=[];iv.value=true}
async function onCc(){ifm.ccid=null;sr.value=[];if(!ifm.cid){ccop.value=[];return};const r=await getClassCoursesByClass(ifm.cid);ccop.value=r||[]}
async function onStu(){if(!ifm.cid||!ifm.ccid){sr.value=[];return};const r=await getStudentList({page:1,pageSize:999,classId:ifm.cid});sr.value=(r?.records||[]).map(s=>({studentId:s.id,studentNo:s.studentNo,name:s.name,score:null}))}
async function doSave(){const list=sr.value.filter(s=>s.score!=null).map(s=>({studentId:s.studentId,classCourseId:ifm.ccid,examType:ifm.et,score:s.score}));if(!list.length){ElMessage.warning('无数据');return};await batchSaveScores(list);ElMessage.success(`保存 ${list.length} 条`);iv.value=false;load()}
async function doDel(id){await ElMessageBox.confirm('确认删除？','提示',{type:'warning'});await deleteScore(id);ElMessage.success('已删除');load()}
</script>

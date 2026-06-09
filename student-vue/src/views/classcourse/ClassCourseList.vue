<template>
  <div class="page-container">
    <div class="page-header"><h2>排课管理</h2><el-button v-if="isAd" type="primary" @click="open()">+ 新增</el-button></div>
    <el-table :data="rows" stripe v-loading="ld" v-if="!ld && rows.length>0">
      <el-table-column prop="className" label="班级" width="140"/><el-table-column prop="courseName" label="课程" width="150"/>
      <el-table-column prop="teacherName" label="教师" width="110"><template #default="{row}"><el-tag size="small">{{ row.teacherName }}</el-tag></template></el-table-column>
      <el-table-column prop="semester" label="学期" width="135"><template #default="{row}"><el-tag size="small">{{ row.semester }}</el-tag></template></el-table-column>
      <el-table-column label="" width="140" fixed="right" v-if="isAd"><template #default="{row}"><el-button size="small" type="primary" link @click="open(row)">编辑</el-button><el-button size="small" type="danger" link @click="doDel(row.id)">删除</el-button></template></el-table-column>
    </el-table>
    <div v-if="!ld && rows.length===0" class="empty-state"><el-empty description="暂无排课数据" /></div>
    <el-pagination v-model:current-page="p" v-model:page-size="ps" :total="total" layout="total,prev,pager,next" @change="load" background/>
    <el-dialog v-model="dv" :title="ed?'编辑':'新增'" width="400px" :close-on-click-modal="false">
      <el-form ref="fr" :model="fm" :rules="frr" label-width="70px">
        <el-form-item label="班级"><el-select v-model="fm.classId" style="width:100%"><el-option v-for="c in co" :key="c.id" :label="c.className" :value="c.id"/></el-select></el-form-item>
        <el-form-item label="课程"><el-select v-model="fm.courseId" style="width:100%"><el-option v-for="c in cro" :key="c.id" :label="c.courseName" :value="c.id"/></el-select></el-form-item>
        <el-form-item label="教师"><el-select v-model="fm.teacherId" style="width:100%"><el-option v-for="t in to" :key="t.id" :label="t.realName" :value="t.id"/></el-select></el-form-item>
        <el-form-item label="学期"><el-input v-model="fm.semester" placeholder="2024-2025-2"/></el-form-item>
      </el-form>
      <template #footer><el-button @click="dv=false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref,reactive,onMounted,computed } from 'vue';import { ElMessage,ElMessageBox } from 'element-plus';import { useAuthStore } from '@/stores';import { getClassCourseList,createClassCourse,updateClassCourse,deleteClassCourse,getClassList,getCourseList,getUserList } from '@/utils/request'
const au=useAuthStore();const isAd=computed(()=>au.isAdmin)
const ld=ref(false);const rows=ref([]);const total=ref(0);const p=ref(1);const ps=ref(10)
const dv=ref(false);const ed=ref(false);const fr=ref(null);const co=ref([]);const cro=ref([]);const to=ref([])
const fm=reactive({id:null,classId:null,courseId:null,teacherId:null,semester:'2024-2025-2'})
const frr={classId:[{required:true}],courseId:[{required:true}],teacherId:[{required:true}],semester:[{required:true}]}
onMounted(async()=>{const[a,b,c]=await Promise.all([getClassList({page:1,pageSize:999}),getCourseList({page:1,pageSize:999}),getUserList({page:1,pageSize:999})]);co.value=a?.records||[];cro.value=b?.records||[];to.value=c?.records||[];load()})
async function load(){ld.value=true;try{const r=await getClassCourseList({page:p.value,pageSize:ps.value});rows.value=r?.records||[];total.value=r?.total||0}finally{ld.value=false}}
function open(row){ed.value=!!row;Object.assign(fm,row?{...row}:{id:null,classId:null,courseId:null,teacherId:null,semester:'2024-2025-2'});dv.value=true;setTimeout(()=>fr.value?.clearValidate(),100)}
async function save(){const v=await fr.value.validate().catch(()=>false);if(!v)return;ed.value?await updateClassCourse(fm.id,fm):await createClassCourse(fm);ElMessage.success('保存成功');dv.value=false;load()}
async function doDel(id){await ElMessageBox.confirm('确认删除？','提示',{type:'warning'});await deleteClassCourse(id);ElMessage.success('已删除');load()}
</script>

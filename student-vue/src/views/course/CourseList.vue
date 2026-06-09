<template>
  <div class="page-container">
    <div class="page-header"><h2>课程管理</h2><el-button v-if="isAd" type="primary" @click="open()">+ 新增</el-button></div>
    <div class="search-bar"><el-input v-model="kw" placeholder="课程名称 / 编号" clearable style="width:220px" @keyup.enter="load"/><el-button type="primary" @click="load">查询</el-button></div>
    <el-table :data="rows" stripe v-loading="ld" v-if="!ld && rows.length>0">
      <el-table-column prop="courseCode" label="编号" width="100"/><el-table-column prop="courseName" label="名称" min-width="160"/>
      <el-table-column label="学分" width="70"><template #default="{row}"><el-tag size="small">{{ row.credit }}</el-tag></template></el-table-column>
      <el-table-column prop="hours" label="课时" width="70"/>
      <el-table-column prop="description" label="描述" min-width="180" show-overflow-tooltip/>
      <el-table-column label="" width="140" fixed="right" v-if="isAd"><template #default="{row}"><el-button size="small" type="primary" link @click="open(row)">编辑</el-button><el-button size="small" type="danger" link @click="doDel(row.id)">删除</el-button></template></el-table-column>
    </el-table>
    <div v-if="!ld && rows.length===0" class="empty-state"><el-empty description="暂无课程数据" /></div>
    <el-pagination v-model:current-page="p" v-model:page-size="ps" :total="total" layout="total,prev,pager,next" @change="load" background/>
    <el-dialog v-model="dv" :title="ed?'编辑':'新增'" width="420px" :close-on-click-modal="false">
      <el-form ref="fr" :model="fm" :rules="frr" label-width="80px">
        <el-form-item label="编号" prop="courseCode"><el-input v-model="fm.courseCode"/></el-form-item>
        <el-form-item label="名称" prop="courseName"><el-input v-model="fm.courseName"/></el-form-item>
        <el-row :gutter="14"><el-col :span="12"><el-form-item label="学分"><el-input-number v-model="fm.credit" :min="0" :max="10" :step="0.5" style="width:100%" controls-position="right"/></el-form-item></el-col><el-col :span="12"><el-form-item label="课时"><el-input-number v-model="fm.hours" :min="0" :max="200" style="width:100%" controls-position="right"/></el-form-item></el-col></el-row>
        <el-form-item label="描述"><el-input v-model="fm.description" type="textarea" :rows="3"/></el-form-item>
      </el-form>
      <template #footer><el-button @click="dv=false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref,reactive,onMounted,computed } from 'vue';import { ElMessage,ElMessageBox } from 'element-plus';import { useAuthStore } from '@/stores';import { getCourseList,createCourse,updateCourse,deleteCourse } from '@/utils/request'
const au=useAuthStore();const isAd=computed(()=>au.isAdmin)
const ld=ref(false);const rows=ref([]);const total=ref(0);const p=ref(1);const ps=ref(10);const kw=ref('')
const dv=ref(false);const ed=ref(false);const fr=ref(null)
const fm=reactive({id:null,courseCode:'',courseName:'',credit:0,hours:0,description:''});const frr={courseCode:[{required:true}],courseName:[{required:true}]}
onMounted(load)
async function load(){ld.value=true;try{const r=await getCourseList({page:p.value,pageSize:ps.value,keyword:kw.value});rows.value=r?.records||[];total.value=r?.total||0}finally{ld.value=false}}
function open(row){ed.value=!!row;Object.assign(fm,row?{...row}:{id:null,courseCode:'',courseName:'',credit:0,hours:0,description:''});dv.value=true;setTimeout(()=>fr.value?.clearValidate(),100)}
async function save(){const v=await fr.value.validate().catch(()=>false);if(!v)return;ed.value?await updateCourse(fm.id,fm):await createCourse(fm);ElMessage.success('保存成功');dv.value=false;load()}
async function doDel(id){await ElMessageBox.confirm('确认删除？','提示',{type:'warning'});await deleteCourse(id);ElMessage.success('已删除');load()}
</script>

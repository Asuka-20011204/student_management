<template>
  <div class="page-container">
    <div class="page-header"><h2>班级管理</h2><el-button v-if="isAd" type="primary" @click="open()">+ 新增</el-button></div>
    <div class="search-bar"><el-input v-model="kw" placeholder="班级名称 / 年级" clearable style="width:220px" @keyup.enter="load"/><el-button type="primary" @click="load">查询</el-button></div>
    <el-table :data="rows" stripe v-loading="ld" v-if="!ld && rows.length>0">
      <el-table-column prop="className" label="名称" min-width="160"/><el-table-column prop="grade" label="年级" width="90"/>
      <el-table-column prop="room" label="教室" width="90"/><el-table-column label="人数" width="70"><template #default="{row}"><el-tag size="small">{{ row.studentCount||0 }}</el-tag></template></el-table-column>
      <el-table-column prop="description" label="描述" min-width="160" show-overflow-tooltip/>
      <el-table-column label="" width="140" fixed="right" v-if="isAd"><template #default="{row}"><el-button size="small" type="primary" link @click="open(row)">编辑</el-button><el-button size="small" type="danger" link @click="doDel(row.id)">删除</el-button></template></el-table-column>
    </el-table>
    <div v-if="!ld && rows.length===0" class="empty-state"><el-empty description="暂无班级数据" /></div>
    <el-pagination v-model:current-page="p" v-model:page-size="ps" :total="total" layout="total,prev,pager,next" @change="load" background/>
    <el-dialog v-model="dv" :title="ed?'编辑':'新增'" width="420px" :close-on-click-modal="false">
      <el-form ref="fr" :model="fm" :rules="frr" label-width="80px">
        <el-form-item label="名称" prop="className"><el-input v-model="fm.className"/></el-form-item>
        <el-form-item label="年级" prop="grade"><el-input v-model="fm.grade"/></el-form-item>
        <el-form-item label="教室"><el-input v-model="fm.room"/></el-form-item>
        <el-form-item label="描述"><el-input v-model="fm.description" type="textarea" :rows="3"/></el-form-item>
      </el-form>
      <template #footer><el-button @click="dv=false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref,reactive,onMounted,computed } from 'vue';import { ElMessage,ElMessageBox } from 'element-plus';import { useAuthStore } from '@/stores';import { getClassList,createClass,updateClass,deleteClass } from '@/utils/request'
const au=useAuthStore();const isAd=computed(()=>au.isAdmin)
const ld=ref(false);const rows=ref([]);const total=ref(0);const p=ref(1);const ps=ref(10);const kw=ref('')
const dv=ref(false);const ed=ref(false);const fr=ref(null)
const fm=reactive({id:null,className:'',grade:'',room:'',description:''});const frr={className:[{required:true}],grade:[{required:true}]}
onMounted(load)
async function load(){ld.value=true;try{const r=await getClassList({page:p.value,pageSize:ps.value,keyword:kw.value});rows.value=r?.records||[];total.value=r?.total||0}finally{ld.value=false}}
function open(row){ed.value=!!row;Object.assign(fm,row?{...row}:{id:null,className:'',grade:'',room:'',description:''});dv.value=true;setTimeout(()=>fr.value?.clearValidate(),100)}
async function save(){const v=await fr.value.validate().catch(()=>false);if(!v)return;ed.value?await updateClass(fm.id,fm):await createClass(fm);ElMessage.success('保存成功');dv.value=false;load()}
async function doDel(id){await ElMessageBox.confirm('确认删除？','提示',{type:'warning'});await deleteClass(id);ElMessage.success('已删除');load()}
</script>

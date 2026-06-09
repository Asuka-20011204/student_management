<template>
  <div class="page-container">
    <div class="page-header"><h2>{{ isTeacherView ? '教师管理' : '用户管理' }}</h2><el-button type="primary" @click="open()">+ 新增{{ isTeacherView ? '教师' : '用户' }}</el-button></div>
    <div class="search-bar">
      <el-input v-model="kw" placeholder="用户名 / 姓名" clearable style="width:200px" @keyup.enter="load"/>
      <el-select v-if="!isTeacherView" v-model="roleFilter" placeholder="角色筛选" clearable style="width:130px" @change="load">
        <el-option v-for="r in ar" :key="r.id" :label="r.roleName" :value="r.id"/>
      </el-select>
      <el-button type="primary" @click="load">查询</el-button>
    </div>
    <el-table :data="rows" stripe v-loading="ld" v-if="!ld && rows.length>0">
      <el-table-column prop="username" label="用户名" width="110"/><el-table-column prop="realName" label="姓名" width="100"/>
      <el-table-column prop="phone" label="电话" width="130"/><el-table-column prop="email" label="邮箱" min-width="160"/>
      <el-table-column prop="roleNames" label="角色" width="140">
        <template #default="{row}"><el-tag v-for="(r,i) in (row.roleNames||[])" :key="i" size="small" type="warning" style="margin-right:4px">{{ r }}</el-tag><span v-if="!row.roleNames?.length" style="color:#999">未分配</span></template>
      </el-table-column>
      <el-table-column label="状态" width="75"><template #default="{row}"><el-tag :type="row.status===1?'success':'danger'" size="small">{{ row.status===1?'启用':'禁用' }}</el-tag></template></el-table-column>
      <el-table-column label="" width="140" fixed="right"><template #default="{row}"><el-button size="small" type="primary" link @click="open(row)">编辑</el-button><el-button size="small" type="danger" link @click="doDel(row.id)">删除</el-button></template></el-table-column>
    </el-table>
    <div v-if="!ld && rows.length===0" class="empty-state"><el-empty :description="'暂无'+ (isTeacherView?'教师':'用户') +'数据'" /></div>
    <el-pagination v-model:current-page="p" v-model:page-size="ps" :total="total" layout="total,prev,pager,next" @change="load" background/>
    <el-dialog v-model="dv" :title="ed?'编辑':'新增'" width="400px" :close-on-click-modal="false">
      <el-form ref="fr" :model="fm" :rules="frr" label-width="80px">
        <el-form-item label="用户名" prop="username"><el-input v-model="fm.username" :disabled="ed"/></el-form-item>
        <el-form-item label="密码" :prop="ed?null:'password'"><el-input v-model="fm.password" type="password" show-password :placeholder="ed?'留空不修改':''"/></el-form-item>
        <el-form-item label="姓名" prop="realName"><el-input v-model="fm.realName"/></el-form-item>
        <el-form-item label="电话"><el-input v-model="fm.phone"/></el-form-item>
        <el-form-item label="邮箱"><el-input v-model="fm.email"/></el-form-item>
        <el-form-item label="角色" prop="roleIds"><el-select v-model="fm.roleIds" multiple placeholder="选择" style="width:100%"><el-option v-for="r in ar" :key="r.id" :label="r.roleName" :value="r.id"/></el-select></el-form-item>
        <el-form-item label="状态"><el-switch v-model="fm.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="禁用"/></el-form-item>
      </el-form>
      <template #footer><el-button @click="dv=false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref,reactive,onMounted,computed } from 'vue';import { useRoute } from 'vue-router';import { ElMessage,ElMessageBox } from 'element-plus';import request,{ getUserList,createUser,updateUser,deleteUser,getAllRoles } from '@/utils/request'
const route=useRoute()
const isTeacherView=computed(()=>route.path==='/teachers')
const ld=ref(false);const rows=ref([]);const total=ref(0);const p=ref(1);const ps=ref(10);const kw=ref('');const roleFilter=ref(null)
const dv=ref(false);const ed=ref(false);const fr=ref(null);const ar=ref([])
const fm=reactive({id:null,username:'',password:'',realName:'',phone:'',email:'',roleIds:[],status:1})
const frr={username:[{required:true}],password:[{required:true,min:6}],realName:[{required:true}],roleIds:[{required:true}]}
const roleMap=ref({})  // id → roleName
onMounted(async()=>{const r=await getAllRoles();ar.value=r||[];r?.forEach(x=>roleMap.value[x.id]=x.roleName);if(isTeacherView.value){const t=ar.value.find(x=>x.roleCode==='ROLE_TEACHER');if(t)roleFilter.value=t.id};load()})
async function load(){ld.value=true;try{const params={page:p.value,pageSize:ps.value,keyword:kw.value};if(roleFilter.value)params.roleId=roleFilter.value;const r=await getUserList(params);const list=r?.records||[];total.value=r?.total||0;for(const u of list){try{const ids=await request.get(`/users/${u.id}/roles`);u.roleNames=(ids||[]).map(id=>roleMap.value[id]||id).filter(Boolean)}catch{u.roleNames=[]}};rows.value=list}finally{ld.value=false}}
async function open(row){ed.value=!!row;if(row){Object.assign(fm,{...row,password:'',roleIds:[]});try{const r=await request.get(`/users/${row.id}/roles`);fm.roleIds=r||[]}catch{fm.roleIds=[]}}else{Object.assign(fm,{id:null,username:'',password:'',realName:'',phone:'',email:'',roleIds:isTeacherView.value?[2]:[],status:1})};dv.value=true;setTimeout(()=>fr.value?.clearValidate(),100)}
async function save(){const v=await fr.value.validate().catch(()=>false);if(!v)return;const p={...fm};if(ed.value&&!p.password)delete p.password;ed.value?await updateUser(fm.id,p):await createUser(p);ElMessage.success('保存成功');dv.value=false;load()}
async function doDel(id){await ElMessageBox.confirm('确认删除？','提示',{type:'warning'});await deleteUser(id);ElMessage.success('已删除');load()}
</script>

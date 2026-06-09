<template>
  <div class="page-container">
    <div class="page-header">
      <h2>学生管理</h2>
      <div style="display:flex;gap:8px">
        <el-button v-if="canDel" type="danger" plain @click="doBatch" :disabled="!sels.length">批量删除 ({{ sels.length }})</el-button>
        <el-button v-if="canEdit" type="primary" @click="open()">+ 新增</el-button>
      </div>
    </div>
    <div class="search-bar">
      <el-input v-model="q.name" placeholder="姓名" clearable style="width:130px" @keyup.enter="load" />
      <el-input v-model="q.studentNo" placeholder="学号" clearable style="width:140px" @keyup.enter="load" />
      <el-select v-model="q.classId" placeholder="班级" clearable style="width:140px"><el-option v-for="c in cos" :key="c.v" :label="c.l" :value="c.v"/></el-select>
      <el-button type="primary" @click="load">查询</el-button>
      <el-button @click="reset">重置</el-button>
    </div>
    <el-table :data="rows" stripe v-loading="ld" @selection-change="onSel" v-if="!ld && rows.length>0">
      <el-table-column type="selection" width="38"/><el-table-column prop="studentNo" label="学号" width="105"/>
      <el-table-column prop="name" label="姓名" width="85"/><el-table-column label="性别" width="55"><template #default="{row}">{{ row.gender===1?'男':row.gender===2?'女':'·' }}</template></el-table-column>
      <el-table-column prop="phone" label="电话" width="125"/><el-table-column prop="className" label="班级" min-width="130"/>
      <el-table-column label="状态" width="80"><template #default="{row}"><el-tag :type="row.status===1?'success':row.status===2?'info':'warning'" size="small">{{ sm[row.status] }}</el-tag></template></el-table-column>
      <el-table-column prop="enrollmentDate" label="入学" width="100"/>
      <el-table-column label="" width="140" fixed="right"><template #default="{row}"><el-button v-if="canEdit" size="small" type="primary" link @click="open(row)">编辑</el-button><el-button v-if="canDel" size="small" type="danger" link @click="doDel(row.id)">删除</el-button></template></el-table-column>
    </el-table>
    <div v-if="!ld && rows.length===0" class="empty-state"><el-empty description="暂无学生数据，点击上方按钮添加" /></div>
    <el-pagination v-model:current-page="q.page" v-model:page-size="q.pageSize" :total="total" :page-sizes="[10,20,50]" layout="total,sizes,prev,pager,next" @change="load" background/>
    <el-dialog v-model="dv" :title="ed?'编辑':'新增'" width="560px" :close-on-click-modal="false">
      <el-form ref="fr" :model="fm" :rules="frr" label-width="78px"><el-row :gutter="14">
        <el-col :span="12"><el-form-item label="学号" prop="studentNo"><el-input v-model="fm.studentNo"/></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="姓名" prop="name"><el-input v-model="fm.name"/></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="性别"><el-select v-model="fm.gender" style="width:100%"><el-option :value="1" label="男"/><el-option :value="2" label="女"/></el-select></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="班级"><el-select v-model="fm.classId" style="width:100%"><el-option v-for="c in cos" :key="c.v" :label="c.l" :value="c.v"/></el-select></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="电话"><el-input v-model="fm.phone"/></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="邮箱"><el-input v-model="fm.email"/></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="生日"><el-date-picker v-model="fm.birthday" type="date" style="width:100%" value-format="YYYY-MM-DD"/></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="入学"><el-date-picker v-model="fm.enrollmentDate" type="date" style="width:100%" value-format="YYYY-MM-DD"/></el-form-item></el-col>
        <el-col :span="12"><el-form-item label="状态"><el-select v-model="fm.status" style="width:100%"><el-option :value="1" label="在读"/><el-option :value="0" label="休学"/><el-option :value="2" label="毕业"/></el-select></el-form-item></el-col>
        <el-col :span="24"><el-form-item label="地址"><el-input v-model="fm.address"/></el-form-item></el-col>
      </el-row></el-form>
      <template #footer><el-button @click="dv=false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup>
import { ref,reactive,onMounted,computed } from 'vue';import { ElMessage,ElMessageBox } from 'element-plus';import { useAuthStore } from '@/stores';import { getStudentList,createStudent,updateStudent,deleteStudent,batchDeleteStudents,getClassList } from '@/utils/request'
const au=useAuthStore();const canEdit=computed(()=>au.isAdmin||au.isTeacher);const canDel=computed(()=>au.isAdmin)
const ld=ref(false);const rows=ref([]);const total=ref(0);const sels=ref([]);const dv=ref(false);const ed=ref(false);const fr=ref(null);const cos=ref([])
const q=reactive({page:1,pageSize:10,name:'',studentNo:'',classId:null})
const fm=reactive({id:null,studentNo:'',name:'',gender:1,classId:null,phone:'',email:'',birthday:'',enrollmentDate:'',status:1,address:''})
const frr={studentNo:[{required:true}],name:[{required:true}]}
const sm={0:'休学',1:'在读',2:'毕业'}
onMounted(async()=>{const r=await getClassList({page:1,pageSize:999});cos.value=(r?.records||[]).map(c=>({v:c.id,l:c.className}));load()})
async function load(){ld.value=true;try{const r=await getStudentList(q);rows.value=r?.records||[];total.value=r?.total||0}finally{ld.value=false}}
function reset(){Object.assign(q,{page:1,name:'',studentNo:'',classId:null});load()}
function onSel(v){sels.value=v.map(x=>x.id)}
function open(row){ed.value=!!row;Object.assign(fm,row?{...row}:{id:null,studentNo:'',name:'',gender:1,classId:null,phone:'',email:'',birthday:'',enrollmentDate:'',status:1,address:''});dv.value=true;setTimeout(()=>fr.value?.clearValidate(),100)}
async function save(){const v=await fr.value.validate().catch(()=>false);if(!v)return;ed.value?await updateStudent(fm.id,fm):await createStudent(fm);ElMessage.success('保存成功');dv.value=false;load()}
async function doDel(id){await ElMessageBox.confirm('确认删除？','提示',{type:'warning'});await deleteStudent(id);ElMessage.success('已删除');load()}
async function doBatch(){await ElMessageBox.confirm(`删除 ${sels.value.length} 条？`,'提示',{type:'warning'});await batchDeleteStudents(sels.value);ElMessage.success('已删除');sels.value=[];load()}
</script>

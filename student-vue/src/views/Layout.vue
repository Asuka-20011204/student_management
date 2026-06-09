<template>
  <div class="lay">
    <aside :class="['sb',{fold:app.sidebarCollapsed}]">
      <div class="sb-hd" @click="$router.push('/dashboard')">
        <el-icon :size="20" color="var(--blue)"><School /></el-icon>
        <span v-if="!app.sidebarCollapsed" class="sb-title">学生管理</span>
      </div>
      <nav class="sb-nav">
        <div v-for="m in menu" :key="m.path"
             :class="['sb-item',{on:route.path===m.path}]" @click="$router.push(m.path)">
          <el-icon :size="16"><component :is="m.icon" /></el-icon>
          <span v-if="!app.sidebarCollapsed" class="sb-lbl">{{ m.label }}</span>
        </div>
      </nav>
      <div class="sb-ft" @click="app.toggleSidebar">
        <el-icon :size="12"><component :is="app.sidebarCollapsed ? 'DArrowRight' : 'DArrowLeft'" /></el-icon>
      </div>
    </aside>

    <div class="mn">
      <header class="tb">
        <span class="tb-tl">{{ curTitle }}</span>
        <div class="tb-rt">
          <span class="tb-usr">{{ auth.user?.realName }}</span>
          <el-dropdown trigger="click" @command="onCmd">
            <div class="tb-av">{{ auth.user?.realName?.charAt(0) }}</div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="pwd">
                  <el-icon><Lock /></el-icon> 修改密码
                </el-dropdown-item>
                <el-dropdown-item command="out" divided>
                  <el-icon><SwitchButton /></el-icon> 退出
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>
      <main class="ct"><router-view /></main>
    </div>

    <el-dialog v-model="pvd" title="修改密码" width="360px" :close-on-click-modal="false">
      <el-form ref="pf" :model="pfm" :rules="pr" label-width="80px">
        <el-form-item label="当前密码"><el-input v-model="pfm.old" type="password" show-password /></el-form-item>
        <el-form-item label="新密码"><el-input v-model="pfm.nw" type="password" show-password /></el-form-item>
        <el-form-item label="确认"><el-input v-model="pfm.cf" type="password" show-password /></el-form-item>
      </el-form>
      <template #footer><el-button @click="pvd=false">取消</el-button><el-button type="primary" @click="doPwd">确认</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref,reactive,computed } from 'vue'
import { useRoute,useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { School,HomeFilled,UserFilled,OfficeBuilding,Notebook,Grid,DataAnalysis,Setting,Lock,SwitchButton,DArrowRight,DArrowLeft } from '@element-plus/icons-vue'
import { useAuthStore,useAppStore } from '@/stores'
import request from '@/utils/request'

const route=useRoute();const router=useRouter()
const auth=useAuthStore();const app=useAppStore()

const curTitle=computed(()=>{const m=menu.value.find(i=>i.path===route.path);return m?.label||'首页'})

const menu=computed(()=>{
  const items=[
    {path:'/dashboard',label:'首页',icon:HomeFilled},
    {path:'/students',label:'学生管理',icon:UserFilled},
    {path:'/classes',label:'班级管理',icon:OfficeBuilding},
    {path:'/courses',label:'课程管理',icon:Notebook},
    {path:'/class-courses',label:'排课管理',icon:Grid},
    {path:'/scores',label:'成绩管理',icon:DataAnalysis},
  ]
  if(auth.isAdmin) items.push({path:'/teachers',label:'教师管理',icon:UserFilled},{path:'/users',label:'用户管理',icon:Setting})
  return items
})

const pvd=ref(false);const pf=ref(null)
const pfm=reactive({old:'',nw:'',cf:''})
const pr={old:[{required:true}],nw:[{required:true,min:6}],cf:[{required:true},{validator:(_,v,cb)=>v===pfm.nw?cb():cb(new Error('不一致')),trigger:'blur'}]}

async function doPwd(){
  const v=await pf.value.validate().catch(()=>false);if(!v)return
  try{await request.put('/auth/password',{oldPassword:pfm.old,newPassword:pfm.nw});ElMessage.success('密码已修改');pvd.value=false}catch{}
}

function onCmd(c){
  if(c==='out'){auth.logout();router.push('/login')}
  else if(c==='pwd'){Object.assign(pfm,{old:'',nw:'',cf:''});pvd.value=true}
}
</script>

<style scoped>
.lay { display:flex; min-height:100dvh; }

.sb {
  width:210px; flex-shrink:0;
  background:var(--glass);
  backdrop-filter:blur(var(--blur));
  -webkit-backdrop-filter:blur(var(--blur));
  border-right:1px solid var(--glass-border);
  display:flex; flex-direction:column;
  transition:width var(--trans);
}
.sb.fold { width:56px; }

.sb-hd {
  height:54px; display:flex; align-items:center; justify-content:center; gap:6px;
  cursor:pointer; border-bottom:1px solid var(--glass-border);
}
.sb-title { font-family:var(--font-display); font-size:16px; font-weight:700; color:var(--blue-dark); letter-spacing:2px; }

.sb-nav { flex:1; padding:8px 8px; overflow-y:auto; }
.sb-item {
  display:flex; align-items:center; gap:10px;
  padding:10px 14px; margin-bottom:2px; border-radius:var(--r-sm);
  cursor:pointer; transition:all var(--trans);
  color:var(--text-sub); font-size:14px; font-weight:500;
  border:1px solid transparent;
}
.sb-item:hover { background:var(--glass-hover); color:var(--blue-dark); }
.sb-item.on {
  background:var(--glass-hover); color:var(--blue-dark); font-weight:700;
  border-color:var(--glass-border); box-shadow:var(--shadow-sm);
}
.sb-lbl { flex:1; }

.sb-ft {
  height:40px; display:flex; align-items:center; justify-content:center;
  border-top:1px solid var(--glass-border); cursor:pointer;
  color:var(--text-dim); transition:var(--trans);
}
.sb-ft:hover { color:var(--blue); }

.mn { flex:1; display:flex; flex-direction:column; min-width:0; }
.tb {
  height:54px; flex-shrink:0;
  background:var(--glass);
  backdrop-filter:blur(var(--blur));
  -webkit-backdrop-filter:blur(var(--blur));
  border-bottom:1px solid var(--glass-border);
  display:flex; align-items:center; justify-content:space-between;
  padding:0 22px;
}
.tb-tl { font-family:var(--font-display); font-size:16px; font-weight:600; color:var(--blue-dark); }
.tb-rt { display:flex; align-items:center; gap:14px; }
.tb-usr { font-size:13px; color:var(--text-sub); font-weight:500; }
.tb-av {
  width:34px; height:34px; border-radius:var(--r-sm);
  background:var(--blue); border:3px solid var(--blue-dark);
  color:#fff; display:flex; align-items:center; justify-content:center;
  font-weight:700; font-size:15px; cursor:pointer;
  box-shadow:var(--shadow-sm); transition:var(--trans);
}
.tb-av:hover { transform:scale(1.1); }

.ct { flex:1; padding:20px; overflow-y:auto; }
</style>

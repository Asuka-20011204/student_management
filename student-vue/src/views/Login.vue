<template>
  <div class="login">
    <!-- 背景装饰圆 -->
    <div class="bg-orb orb-1"></div>
    <div class="bg-orb orb-2"></div>
    <div class="bg-orb orb-3"></div>

    <div class="login-box">
      <div class="box-icon">
        <el-icon :size="44" color="var(--blue)"><School /></el-icon>
      </div>
      <h1>学生管理系统</h1>
      <p class="sub">Student Management System</p>

      <el-form ref="f" :model="fm" :rules="r" size="large" @submit.prevent="go">
        <el-form-item prop="username">
          <el-input v-model="fm.username" placeholder="用户名" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="fm.password" type="password" placeholder="密码" show-password :prefix-icon="Lock" @keyup.enter="go" />
        </el-form-item>
        <el-button type="primary" native-type="submit" :loading="ld" class="go-btn">
          {{ ld ? '验证中...' : '登 录' }}
        </el-button>
      </el-form>

      <p class="tip">提示：admin / 123456</p>
    </div>
  </div>
</template>

<script setup>
import { ref,reactive } from 'vue';import { useRouter } from 'vue-router';import { ElMessage } from 'element-plus';import { School,User,Lock } from '@element-plus/icons-vue';import { useAuthStore } from '@/stores/auth'
const router=useRouter();const auth=useAuthStore();const f=ref(null);const ld=ref(false)
const fm=reactive({username:'admin',password:'123456'})
const r={username:[{required:true,message:'请输入用户名'}],password:[{required:true,message:'请输入密码'}]}
async function go(){const v=await f.value.validate().catch(()=>false);if(!v)return;ld.value=true;try{await auth.login(fm.username,fm.password);ElMessage.success('登录成功');router.push('/')}catch{}finally{ld.value=false}}
</script>

<style scoped>
.login {
  min-height:100dvh; display:flex; align-items:center; justify-content:center;
  background:var(--bg); position:relative; overflow:hidden;
}

/* 背景柔和光晕 */
.bg-orb {
  position:absolute; border-radius:50%; pointer-events:none;
}
.orb-1 {
  width:360px; height:360px; right:-60px; top:-80px;
  background:radial-gradient(circle, rgba(91,141,239,.12), transparent 70%);
}
.orb-2 {
  width:280px; height:280px; left:-40px; bottom:-60px;
  background:radial-gradient(circle, rgba(64,112,204,.10), transparent 70%);
}
.orb-3 {
  width:200px; height:200px; left:50%; top:10%;
  background:radial-gradient(circle, rgba(91,141,239,.06), transparent 70%);
  transform:translateX(-50%);
}

.login-box {
  position:relative; z-index:2;
  width:420px; padding:44px 40px 36px;
  background:var(--glass-strong);
  backdrop-filter:blur(var(--blur-strong));
  -webkit-backdrop-filter:blur(var(--blur-strong));
  border:1px solid var(--glass-border);
  border-radius:var(--r-lg);
  box-shadow:var(--shadow-lg);
  text-align:center;
}
.box-icon {
  margin-bottom:10px; display:flex; justify-content:center;
}
.login-box h1 {
  font-family:var(--font-display); font-size:26px; font-weight:700;
  color:var(--blue-dark); letter-spacing:2px; margin-bottom:4px;
}
.sub {
  font-family:var(--font-ui); font-size:12px; color:var(--text-dim);
  letter-spacing:3px; text-transform:uppercase; margin-bottom:30px;
}
.go-btn {
  width:100% !important; height:48px !important;
  font-size:17px !important; letter-spacing:6px !important; margin-top:6px !important;
}
.tip {
  margin-top:22px; font-size:12px; color:var(--text-dim);
  font-family:var(--font-ui);
}
</style>

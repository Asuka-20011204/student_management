<template>
  <div class="dash">
    <!-- 欢迎横幅 -->
    <div class="banner">
      <div class="bn-l">
        <el-icon :size="28" color="var(--blue)"><Sunny /></el-icon>
        <div>
          <h2>{{ greet }}，{{ auth.user?.realName }}</h2>
          <p>{{ today }} · {{ auth.roles.map(r=>roleTag[r]).join(' / ') }}</p>
        </div>
      </div>
      <div class="bn-r">
        <span class="bn-tag" v-for="r in auth.roles" :key="r">{{ roleTag[r] }}</span>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stat-cards">
      <div class="stat-card">
        <div class="sc-hd"><el-icon :size="22" color="var(--blue)"><UserFilled /></el-icon></div>
        <div class="value">{{ stats.students }}</div>
        <div class="label">学生总数</div>
      </div>
      <div class="stat-card">
        <div class="sc-hd"><el-icon :size="22" color="var(--ok)"><OfficeBuilding /></el-icon></div>
        <div class="value">{{ stats.classes }}</div>
        <div class="label">班级数量</div>
      </div>
      <div class="stat-card">
        <div class="sc-hd"><el-icon :size="22" color="var(--warn)"><Notebook /></el-icon></div>
        <div class="value">{{ stats.courses }}</div>
        <div class="label">课程总数</div>
      </div>
      <div class="stat-card">
        <div class="sc-hd"><el-icon :size="22" color="var(--info)"><Grid /></el-icon></div>
        <div class="value">{{ stats.classCourses }}</div>
        <div class="label">排课记录</div>
      </div>
    </div>

    <!-- 图表 + 模块快捷入口 -->
    <div class="dash-grid">
      <div class="chart-box">
        <div class="chart-hd">各班级学生分布</div>
        <div ref="cr" style="height:280px"></div>
      </div>
      <div class="mod-box">
        <div class="chart-hd">快捷功能</div>
        <div class="mod-grid">
          <div v-for="m in mods" :key="m.path" class="mcard" @click="$router.push(m.path)">
            <el-icon :size="26" :color="m.color"><component :is="m.icon" /></el-icon>
            <span class="mc-lbl">{{ m.label }}</span>
            <span class="mc-sub">{{ m.sub }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref,reactive,computed,onMounted,onUnmounted,nextTick } from 'vue'
import { Sunny,UserFilled,OfficeBuilding,Notebook,Grid,DataAnalysis } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores'
import { getStudentList,getClassList,getCourseList,getClassCourseList } from '@/utils/request'
import * as echarts from 'echarts'

const auth=useAuthStore()
const roleTag={ROLE_ADMIN:'管理员',ROLE_TEACHER:'教师',ROLE_STUDENT:'学生'}

const greet=computed(()=>{
  const h=new Date().getHours()
  return h<6?'夜深了':h<9?'早上好':h<12?'上午好':h<14?'中午好':h<18?'下午好':'晚上好'
})

const today=new Date().toLocaleDateString('zh-CN',{year:'numeric',month:'long',day:'numeric',weekday:'long'})

const stats=reactive({students:'--',classes:'--',courses:'--',classCourses:'--'})

const mods=[
  {path:'/students',icon:UserFilled,color:'var(--blue)',label:'学生管理',sub:'信息与档案'},
  {path:'/classes',icon:OfficeBuilding,color:'var(--ok)',label:'班级管理',sub:'班级设置'},
  {path:'/courses',icon:Notebook,color:'var(--warn)',label:'课程管理',sub:'课程库维护'},
  {path:'/class-courses',icon:Grid,color:'var(--info)',label:'排课管理',sub:'课程分配'},
  {path:'/scores',icon:DataAnalysis,color:'#8b5cf6',label:'成绩管理',sub:'成绩与统计'},
]

const cr=ref(null)
let ch=null

onMounted(async()=>{
  try{
    const [sa,sb,sc,sd]=await Promise.all([
      getStudentList({page:1,pageSize:1}),
      getClassList({page:1,pageSize:1}),
      getCourseList({page:1,pageSize:1}),
      getClassCourseList({page:1,pageSize:1})
    ])
    stats.students=sa?.total??0
    stats.classes=sb?.total??0
    stats.courses=sc?.total??0
    stats.classCourses=sd?.total??0
  }catch{}

  // 班级学生分布图表
  try{
    const r=await getClassList({page:1,pageSize:999})
    const classes=r?.records||[]
    await nextTick()
    if(cr.value){
      ch=echarts.init(cr.value)
      ch.setOption({
        tooltip:{trigger:'axis'},
        grid:{left:'3%',right:'8%',bottom:'3%',top:'8%',containLabel:true},
        xAxis:{type:'category',data:classes.map(c=>c.className),axisLabel:{fontSize:11}},
        yAxis:{type:'value',name:'学生数'},
        series:[{
          type:'bar',
          data:classes.map(c=>c.studentCount||0),
          itemStyle:{
            borderRadius:[6,6,0,0],
            color:new echarts.graphic.LinearGradient(0,0,0,1,[
              {offset:0,color:'#5b8def'},{offset:1,color:'#a8c8fa'}
            ])
          },
          barWidth:'50%'
        }]
      })
    }
  }catch{}
})

onUnmounted(()=>ch?.dispose())
</script>

<style scoped>
.banner {
  display:flex; justify-content:space-between; align-items:center;
  padding:24px 28px; margin-bottom:18px;
  background:var(--glass);
  backdrop-filter:blur(var(--blur));
  -webkit-backdrop-filter:blur(var(--blur));
  border:1px solid var(--glass-border);
  border-radius:var(--r-lg); box-shadow:var(--shadow);
}
.bn-l { display:flex; align-items:center; gap:14px; }
.banner h2 { font-family:var(--font-display); font-size:20px; font-weight:700; color:var(--blue-dark); margin-bottom:3px; }
.banner p { font-size:13px; color:var(--text-sub); }
.bn-r { display:flex; gap:6px; }
.bn-tag {
  padding:5px 14px; font-size:12px; font-weight:600;
  background:var(--glass); border:1px solid var(--glass-border);
  border-radius:16px; color:var(--blue-dark);
}

/* 统计卡片 */
.stat-cards {
  display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:18px;
}
@media (max-width:900px){ .stat-cards{grid-template-columns:repeat(2,1fr)} }
.stat-card {
  padding:18px 20px;
  background:var(--glass);
  backdrop-filter:blur(var(--blur));
  -webkit-backdrop-filter:blur(var(--blur));
  border:1px solid var(--glass-border);
  border-radius:var(--r-md); box-shadow:var(--shadow-sm);
  transition:all var(--trans);
}
.stat-card:hover { transform:translateY(-3px); box-shadow:var(--shadow-lg); }
.sc-hd { margin-bottom:10px; }
.stat-card .value {
  font-family:var(--font-display); font-size:28px; font-weight:700; color:var(--blue-dark);
}
.stat-card .label { font-size:12px; font-weight:600; color:var(--text-sub); margin-top:2px; }

/* 双列布局 */
.dash-grid { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
@media (max-width:900px){ .dash-grid{grid-template-columns:1fr} }

.chart-box, .mod-box {
  padding:18px 20px;
  background:var(--glass);
  backdrop-filter:blur(var(--blur));
  -webkit-backdrop-filter:blur(var(--blur));
  border:1px solid var(--glass-border);
  border-radius:var(--r-md); box-shadow:var(--shadow-sm);
}
.chart-hd {
  font-family:var(--font-display); font-size:15px; font-weight:700;
  color:var(--blue-dark); margin-bottom:12px; letter-spacing:.5px;
}

/* 快捷模块 */
.mod-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:10px; }
.mcard {
  padding:18px 16px; cursor:pointer;
  background:var(--glass-light);
  backdrop-filter:blur(6px);
  -webkit-backdrop-filter:blur(6px);
  border:1px solid var(--glass-border);
  border-radius:var(--r-sm);
  transition:all var(--trans);
  display:flex; flex-direction:column; align-items:center; gap:4px; text-align:center;
}
.mcard:hover {
  background:var(--glass-hover); transform:translateY(-2px);
  box-shadow:var(--shadow-sm);
}
.mc-lbl {
  font-family:var(--font-display); font-size:14px; font-weight:700; color:var(--blue-dark);
}
.mc-sub { font-size:11px; color:var(--text-sub); }
</style>

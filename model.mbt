///|
pub struct TaskSpec {
  id : String
  duration : Int
  deps : Array[String]
  label : String
} derive(Eq, @debug.Debug)

///|
pub struct GraphSpec {
  tasks : Array[TaskSpec]
} derive(Eq, @debug.Debug)

///|
pub struct TaskNode {
  id : String
  duration : Int
  deps : Array[Int]
  dependents : Array[Int]
  label : String
} derive(Eq, @debug.Debug)

///|
pub struct Dag {
  nodes : Array[TaskNode]
  order : Array[Int]
  layers : Array[Array[Int]]
} derive(Eq, @debug.Debug)

///|
/// A duration estimate attached to a task from MoonFlowGraph.
pub struct TaskEstimate {
  id : String
  duration : Int
} derive(Eq, @debug.Debug)

///|
pub fn TaskEstimate::new(id : String, duration : Int) -> TaskEstimate {
  { id, duration }
}

///|
pub fn TaskEstimate::id(self : TaskEstimate) -> String {
  self.id
}

///|
pub fn TaskEstimate::duration(self : TaskEstimate) -> Int {
  self.duration
}

///|
pub struct CriticalPath {
  task_ids : Array[String]
  duration : Int
} derive(Eq, @debug.Debug)

///|
pub struct Analysis {
  order : Array[String]
  layers : Array[Array[String]]
  critical_path : CriticalPath
} derive(Eq, @debug.Debug)

///|
pub struct GraphStats {
  tasks : Int
  edges : Int
  roots : Int
  leaves : Int
  total_duration : Int
  critical_duration : Int
  max_fan_in : Int
  max_fan_out : Int
  layer_count : Int
  parallelism_hint : Int
} derive(Eq, @debug.Debug)

///|
pub struct TaskInfo {
  id : String
  duration : Int
  label : String
  dependencies : Array[String]
  dependents : Array[String]
  blockers : Array[String]
  downstream : Array[String]
  earliest_start : Int
  earliest_finish : Int
  latest_start : Int
  latest_finish : Int
  slack : Int
  critical : Bool
} derive(Eq, @debug.Debug)

///|
pub struct ImpactPlan {
  changed : Array[String]
  affected : Array[String]
  unaffected : Array[String]
  affected_duration : Int
  affected_critical_tasks : Array[String]
  rebuild_layers : Array[Array[String]]
} derive(Eq, @debug.Debug)

///|
pub fn TaskSpec::make(
  id : String,
  duration? : Int = 1,
  deps? : Array[String] = [],
  label? : String = "",
) -> TaskSpec {
  { id, duration, deps: deps.copy(), label }
}

///|
pub fn TaskSpec::id(self : TaskSpec) -> String {
  self.id
}

///|
pub fn TaskSpec::duration(self : TaskSpec) -> Int {
  self.duration
}

///|
pub fn TaskSpec::deps(self : TaskSpec) -> Array[String] {
  self.deps.copy()
}

///|
pub fn TaskSpec::label(self : TaskSpec) -> String {
  self.label
}

///|
pub fn GraphSpec::make(tasks : Array[TaskSpec]) -> GraphSpec {
  { tasks: tasks.copy() }
}

///|
pub fn GraphSpec::tasks(self : GraphSpec) -> Array[TaskSpec] {
  self.tasks.copy()
}

///|
pub fn Dag::nodes(self : Dag) -> Array[TaskNode] {
  self.nodes.copy()
}

///|
pub fn Dag::len(self : Dag) -> Int {
  self.nodes.length()
}

///|
pub fn Dag::is_empty(self : Dag) -> Bool {
  self.nodes.is_empty()
}

///|
pub fn CriticalPath::task_ids(self : CriticalPath) -> Array[String] {
  self.task_ids.copy()
}

///|
pub fn CriticalPath::duration(self : CriticalPath) -> Int {
  self.duration
}

///|
pub fn Analysis::order(self : Analysis) -> Array[String] {
  self.order.copy()
}

///|
pub fn Analysis::layers(self : Analysis) -> Array[Array[String]] {
  self.layers.map(fn(layer) { layer.copy() })
}

///|
pub fn Analysis::critical_path(self : Analysis) -> CriticalPath {
  self.critical_path
}

///|
pub fn GraphStats::tasks(self : GraphStats) -> Int {
  self.tasks
}

///|
pub fn GraphStats::edges(self : GraphStats) -> Int {
  self.edges
}

///|
pub fn GraphStats::roots(self : GraphStats) -> Int {
  self.roots
}

///|
pub fn GraphStats::leaves(self : GraphStats) -> Int {
  self.leaves
}

///|
pub fn GraphStats::total_duration(self : GraphStats) -> Int {
  self.total_duration
}

///|
pub fn GraphStats::critical_duration(self : GraphStats) -> Int {
  self.critical_duration
}

///|
pub fn GraphStats::max_fan_in(self : GraphStats) -> Int {
  self.max_fan_in
}

///|
pub fn GraphStats::max_fan_out(self : GraphStats) -> Int {
  self.max_fan_out
}

///|
pub fn GraphStats::layer_count(self : GraphStats) -> Int {
  self.layer_count
}

///|
pub fn GraphStats::parallelism_hint(self : GraphStats) -> Int {
  self.parallelism_hint
}

///|
pub fn TaskInfo::id(self : TaskInfo) -> String {
  self.id
}

///|
pub fn TaskInfo::duration(self : TaskInfo) -> Int {
  self.duration
}

///|
pub fn TaskInfo::label(self : TaskInfo) -> String {
  self.label
}

///|
pub fn TaskInfo::dependencies(self : TaskInfo) -> Array[String] {
  self.dependencies.copy()
}

///|
pub fn TaskInfo::dependents(self : TaskInfo) -> Array[String] {
  self.dependents.copy()
}

///|
pub fn TaskInfo::blockers(self : TaskInfo) -> Array[String] {
  self.blockers.copy()
}

///|
pub fn TaskInfo::downstream(self : TaskInfo) -> Array[String] {
  self.downstream.copy()
}

///|
pub fn TaskInfo::earliest_start(self : TaskInfo) -> Int {
  self.earliest_start
}

///|
pub fn TaskInfo::earliest_finish(self : TaskInfo) -> Int {
  self.earliest_finish
}

///|
pub fn TaskInfo::latest_start(self : TaskInfo) -> Int {
  self.latest_start
}

///|
pub fn TaskInfo::latest_finish(self : TaskInfo) -> Int {
  self.latest_finish
}

///|
pub fn TaskInfo::slack(self : TaskInfo) -> Int {
  self.slack
}

///|
pub fn TaskInfo::is_critical(self : TaskInfo) -> Bool {
  self.critical
}

///|
pub fn ImpactPlan::changed(self : ImpactPlan) -> Array[String] {
  self.changed.copy()
}

///|
pub fn ImpactPlan::affected(self : ImpactPlan) -> Array[String] {
  self.affected.copy()
}

///|
pub fn ImpactPlan::unaffected(self : ImpactPlan) -> Array[String] {
  self.unaffected.copy()
}

///|
pub fn ImpactPlan::affected_duration(self : ImpactPlan) -> Int {
  self.affected_duration
}

///|
pub fn ImpactPlan::affected_critical_tasks(self : ImpactPlan) -> Array[String] {
  self.affected_critical_tasks.copy()
}

///|
pub fn ImpactPlan::rebuild_layers(self : ImpactPlan) -> Array[Array[String]] {
  self.rebuild_layers.map(fn(layer) { layer.copy() })
}

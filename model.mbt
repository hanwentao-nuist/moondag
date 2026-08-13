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
} derive(Eq, @debug.Debug)

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

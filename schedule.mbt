///|
pub struct TaskTiming {
  id : String
  duration : Int
  earliest_start : Int
  earliest_finish : Int
  latest_start : Int
  latest_finish : Int
  slack : Int
  critical : Bool
} derive(Eq, @debug.Debug)

///|
pub struct Schedule {
  duration : Int
  entries : Array[TaskTiming]
} derive(Eq, @debug.Debug)

///|
pub fn TaskTiming::id(self : TaskTiming) -> String {
  self.id
}

///|
pub fn TaskTiming::duration(self : TaskTiming) -> Int {
  self.duration
}

///|
pub fn TaskTiming::earliest_start(self : TaskTiming) -> Int {
  self.earliest_start
}

///|
pub fn TaskTiming::earliest_finish(self : TaskTiming) -> Int {
  self.earliest_finish
}

///|
pub fn TaskTiming::latest_start(self : TaskTiming) -> Int {
  self.latest_start
}

///|
pub fn TaskTiming::latest_finish(self : TaskTiming) -> Int {
  self.latest_finish
}

///|
pub fn TaskTiming::slack(self : TaskTiming) -> Int {
  self.slack
}

///|
pub fn TaskTiming::is_critical(self : TaskTiming) -> Bool {
  self.critical
}

///|
pub fn Schedule::duration(self : Schedule) -> Int {
  self.duration
}

///|
pub fn Schedule::entries(self : Schedule) -> Array[TaskTiming] {
  self.entries.copy()
}

///|
fn reverse_indexes(values : Array[Int]) -> Array[Int] {
  let result = []
  let mut index = values.length()
  while index > 0 {
    index = index - 1
    result.push(values[index])
  }
  result
}

///|
pub fn Dag::schedule(self : Dag) -> Schedule {
  if self.nodes.is_empty() {
    return { duration: 0, entries: [] }
  }
  let order = topo_indexes(self)
  let earliest_start = self.nodes.map(fn(_) { 0 })
  let earliest_finish = self.nodes.map(fn(_) { 0 })
  let mut project_duration = 0
  for index in order {
    let mut start = 0
    for dep in self.nodes[index].deps {
      if earliest_finish[dep] > start {
        start = earliest_finish[dep]
      }
    }
    earliest_start[index] = start
    earliest_finish[index] = start + self.nodes[index].duration
    if earliest_finish[index] > project_duration {
      project_duration = earliest_finish[index]
    }
  }
  let latest_finish = self.nodes.map(fn(_) { project_duration })
  let latest_start = self.nodes.map(fn(_) { 0 })
  for index in reverse_indexes(order) {
    if !self.nodes[index].dependents.is_empty() {
      let mut finish = project_duration
      for child_index, child in self.nodes[index].dependents {
        if child_index == 0 || latest_start[child] < finish {
          finish = latest_start[child]
        }
      }
      latest_finish[index] = finish
    }
    latest_start[index] = latest_finish[index] - self.nodes[index].duration
  }
  let entries = []
  for index in order {
    let slack = latest_start[index] - earliest_start[index]
    entries.push({
      id: self.nodes[index].id,
      duration: self.nodes[index].duration,
      earliest_start: earliest_start[index],
      earliest_finish: earliest_finish[index],
      latest_start: latest_start[index],
      latest_finish: latest_finish[index],
      slack,
      critical: slack == 0,
    })
  }
  { duration: project_duration, entries }
}

///|
pub fn Schedule::to_text(self : Schedule) -> String {
  let output = StringBuilder::new()
  output.write_string("SCHEDULE duration=" + self.duration.to_string())
  for entry in self.entries {
    output.write_string(
      "\n" +
      entry.id +
      " dur=" +
      entry.duration.to_string() +
      " es=" +
      entry.earliest_start.to_string() +
      " ef=" +
      entry.earliest_finish.to_string() +
      " ls=" +
      entry.latest_start.to_string() +
      " lf=" +
      entry.latest_finish.to_string() +
      " slack=" +
      entry.slack.to_string() +
      " critical=" +
      entry.critical.to_string(),
    )
  }
  output.to_string()
}

///|
fn dot_escape(source : String) -> String {
  let output = StringBuilder::new()
  for char in source {
    match char {
      '"' => output.write_string("\\\"")
      '\\' => output.write_string("\\\\")
      '\n' => output.write_string("\\n")
      other => output.write_char(other)
    }
  }
  output.to_string()
}

///|
pub fn Dag::to_dot(self : Dag) -> String {
  let schedule = self.schedule()
  let output = StringBuilder::new()
  output.write_string("digraph moondag {\n  rankdir=LR;\n")
  for entry in schedule.entries {
    let style = if entry.critical { ", color=\"red\"" } else { "" }
    output.write_string(
      "  \"" +
      dot_escape(entry.id) +
      "\" [label=\"" +
      dot_escape(entry.id + " (" + entry.duration.to_string() + ")") +
      "\"" +
      style +
      "];\n",
    )
  }
  for node in self.nodes {
    for dep in node.deps {
      output.write_string(
        "  \"" +
        dot_escape(self.nodes[dep].id) +
        "\" -> \"" +
        dot_escape(node.id) +
        "\";\n",
      )
    }
  }
  output.write_string("}\n")
  output.to_string()
}

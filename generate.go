package main

import (
    "fmt"
    "os"
    "io/ioutil"
    "strings"
    "math/rand"
    "strconv"
    "time"
    )

func repl(tpl string, k string, v string) string {
  return strings.Replace(tpl, "{{"+ k + "}}", v, -1)
}

func sample(dict []string) string {
  return dict[rand.Intn(len(dict) - 1 )]
}

func main() {
  var m map[string][]string
    m = make(map[string][]string)

    dirname := "./data"
    d, err := os.Open(dirname)
    if err != nil { fmt.Println(err); os.Exit(1) }

  defer d.Close()
    fi, err := d.Readdir(-1)
    if err != nil { fmt.Println(err); os.Exit(1) }

  for _, fi := range fi {
    content, err := ioutil.ReadFile("data/" + fi.Name())
      if err != nil {}
    m[fi.Name()] = strings.Split(string(content), "\n")
  }

  file, e := ioutil.ReadFile("./template.json")
    if e != nil { fmt.Printf("File error: %v\n", e); os.Exit(1) }

  json_tpl := strings.Replace(string(file), "\n", " ", -1)
  /* json_tpl := string(file) */
  /* fmt.Printf("%v", m) */

  limit, e := strconv.ParseInt(os.Args[1], 10, 0)
  if e != nil {
    fmt.Printf("File error: %v\n", e)
    os.Exit(1)
  }

  for i := 0; int64(i) < limit; i++ {
    res := json_tpl
    res = repl(res, "i", strconv.Itoa(i))
    res = repl(res, "id", strconv.Itoa(i))
    t := time.Date(2009 + rand.Intn(5), time.Month(rand.Intn(11)), rand.Intn(25), rand.Intn(24), rand.Intn(60), 0, 0, time.Local)
    t_end := t.Add(time.Duration(rand.Intn(1000)) * time.Hour)
    res = repl(res, "start_time", t.UTC().Format(time.RFC3339))
    res = repl(res, "end_time", t_end.UTC().Format(time.RFC3339))
    for k, v := range m {
      res = repl(res, k, sample(v))
    }
    fmt.Println(res)
  }
}

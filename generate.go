package main

import (
    "fmt"
    "os"
    "io/ioutil"
    "strings"
    "math/rand"
    "text/template"
    "strconv"
    "bytes"
    "time"
    )

func repl(tpl string, k string, v string) string {
  return strings.Replace(tpl, "{{"+ k + "}}", v, -1)
}

func sample(dict []string) string {
  return dict[rand.Intn(len(dict) - 1 )]
}

func strip_new_lines (str string) string {
  return strings.Replace(str, "\n", " ", -1)
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

  tpl, err := template.New("test").Parse(string(file))

    limit, e := strconv.ParseInt(os.Args[1], 10, 0)
    if e != nil { fmt.Printf("File error: %v\n", e); os.Exit(1) }

  for i := 0; int64(i) < limit; i++ {
    var mdl map[string]interface{}
    mdl = make(map[string]interface{})
      mdl["id"] = i
      mdl["i"] = i
      t := time.Date(2009 + rand.Intn(5), time.Month(rand.Intn(11)), rand.Intn(25), rand.Intn(24), rand.Intn(60), 0, 0, time.Local)
      mdl["start_time"]  = t
      mdl["end_time"]   = t.Add(time.Duration(rand.Intn(1000)) * time.Hour)
      for k, v := range m {
        mdl[k]=sample(v)
      }
    /* fmt.Printf("%v", mdl) */

      var buf bytes.Buffer
      err = tpl.Execute(&buf, mdl)
      if err != nil { fmt.Println(err); os.Exit(1) }

    fmt.Println(strip_new_lines(string(buf.String())))
  }
}

package main

import (
    "fmt"
    "os"
    "io/ioutil"
    "strings"
    "math/rand"
    "strconv"
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
    for k, v := range m {
      res = repl(res, k, sample(v))
    }
    fmt.Println(res)
  }
}

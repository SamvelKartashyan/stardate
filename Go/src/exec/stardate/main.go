package main

import (
	"flag"
	"log"
	"os"
	"stardate"
	"time"
)

func printtln(short bool, t time.Time, nl bool) {
	sd := stardate.New(t)
	var txt string
	if short {
		txt = sd.Short()
	} else {
		txt = sd.Canonical()
	}
	if nl {
		txt = txt + "\n"
	}
	os.Stdout.Write([]byte(txt))
}

func main() {
	var email = flag.Bool("email", false, "Use email date format")
	var git = flag.Bool("git", false, "Use git date format")
	var mtime = flag.Bool("mtime", false, "Use modification time of files")
	var nl = flag.Bool("nl", false, "Use newline")
	var short = flag.Bool("short", false, "Use short form")
	flag.Parse()
	var f string
	if *email {
		f = "Mon, 2 Jan 2006 15:04:05 -0700"
	} else if *git {
		f = "Mon Jan 2 15:04:05 2006 -0700"
	} else {
		f = "2006-01-02 15:04:05 -0700"
	}
	args := flag.Args()
	if len(args) > 0 {
		for i := range args {
			var t time.Time
			var err error
			if *mtime {
				var s os.FileInfo
				s, err = os.Stat(args[i])
				if err == nil {
					t = s.ModTime()
				}
			} else {
				t, err = time.Parse(f, args[i])
			}
			if err != nil {
				log.Fatalln(err)
			}
			printtln(*short, t, *nl)
		}
	} else {
		printtln(*short, time.Now(), *nl)
	}
}

// vim: noet sts=2 sw=2 ts=2

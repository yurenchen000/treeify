from
> Projects moved to standalone repositories:
>  - `mpris` ⇒ https://git.nullroute.lt/cgit/hacks/mpris.git/


treeify
=======


```
$ find /etc/apt -iname '*.list' | /tmp/treeify 
[/]
 └─[etc]
    └─[apt]
       ├─sources.list
       └─[sources.list.d]
          └─google-chrome.list
```

<br>

TODO: empty folder item maybe collpased ?
```
[/etc/apt]
 ├─sources.list
 └─[sources.list.d]
    └─google-chrome.list
```

<br>

similar tool:  
https://github.com/dzamlo/treeify

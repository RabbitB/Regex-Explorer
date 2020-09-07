# Regex Explorer
### [Releases available on itch.io](https://dfaction.itch.io/regex-explorer)

A simple file directory explorer that supports compound regex renaming of files and directories, with live preview of changes. The intent of the project is to provide similar utility as can be found in tools like Microsoft's **PowerRename**, but easier to write and perform complex regex operations.

## Compound Expressions

There is no limit to the number of expressions you can run file-names through, and expressions and their replacement content support both numbered and named capture groups. This makes tasks that would otherwise require complex expressions, simple and easy to write once the solution is broken up into multiple steps.

![Capture Groups](https://github.com/RabbitB/Regex-Explorer/blob/master/Assets/Docs/Images/regex_capture_groups.png?raw=true)
This example shows how you can easily pad numbers with leading zeros, by using two expressions, instead of a single, complicated expression. The example also shows how to use both numbered and named capture groups.

## Working With Files

Both files and expressions support toggling on and off, so you can rename only the files you want, and preview different combinations of changes. Expressions also support drag-and-drop to rearrange their order of operation.

![Toggle Files & Expressions](https://github.com/RabbitB/Regex-Explorer/blob/master/Assets/Docs/Images/regex_toggle.png?raw=true)

## Built With the Godot Engine

Regex Explorer was built using the [Godot Engine](https://godotengine.org/), and is licensed under the [MIT license](https://raw.githubusercontent.com/RabbitB/Regex-Explorer/master/LICENSE.md). This makes the utility easy to understand and modify if additional functionality is needed, and all code is reviewable to ensure it's not doing anything you don't intend it to do. Also useful for reviewing if you intend to work on your own Godot based projects.

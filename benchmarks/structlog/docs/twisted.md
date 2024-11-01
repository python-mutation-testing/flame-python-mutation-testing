# Twisted

:::{warning}
Since `sys.exc_clear` has been dropped in Python 3, there is currently no way to avoid multiple tracebacks in your log files if using *structlog* together with Twisted on Python 3.
:::

:::{note}
*structlog* currently only supports the legacy -- but still perfectly working -- Twisted logging system found in `twisted.python.log`.
:::


## Concrete Bound Logger

To make *structlog*'s behavior less magical, it ships with a Twisted-specific wrapper class that has an explicit API instead of improvising: `structlog.twisted.BoundLogger`.
It behaves exactly like the generic `structlog.BoundLogger` except:

- it's slightly faster due to less overhead,
- has an explicit API ({func}`~structlog.twisted.BoundLogger.msg` and {func}`~structlog.twisted.BoundLogger.err`),
- hence causing less cryptic error messages if you get method names wrong.

In order to avoid that *structlog* disturbs your CamelCase harmony, it comes with an alias for `structlog.get_logger` called `structlog.getLogger`.


## Processors

*structlog* comes with two Twisted-specific processors:

{func}`structlog.twisted.EventAdapter`

: This is useful if you have an existing Twisted application and just want to wrap your loggers for now.
  It takes care of transforming your event dictionary into something [twisted.python.log.err](https://docs.twisted.org/en/stable/api/twisted.python.log.html#err) can digest.

  For example:

  ```python
  def onError(fail):
     failure = fail.trap(MoonExploded)
     log.err(failure, _why="event-that-happened")
  ```

  will still work as expected.

  Needs to be put at the end of the processing chain.
  It formats the event using a renderer that needs to be passed into the constructor:

  ```python
  configure(processors=[EventAdapter(KeyValueRenderer()])
  ```

  The drawback of this approach is that Twisted will format your exceptions as multi-line log entries which is painful to parse.
  Therefore *structlog* comes with:

{func}`structlog.twisted.JSONRenderer`

: Goes a step further and circumvents Twisted logger's Exception / Failure handling and renders it itself as JSON strings.
  That gives you regular and simple-to-parse single-line JSON log entries no matter what happens.


## Bending Foreign Logging To Your Will

*structlog* comes with a wrapper for Twisted's log observers to ensure the rest of your logs are in JSON too: `structlog.twisted.JSONLogObserverWrapper`.

What it does is determining whether a log entry has been formatted by `structlog.twisted.JSONRenderer`  and if not, converts the log entry to JSON with `event` being the log message and putting Twisted's `system` into a second key.

So for example:

```
2013-09-15 22:02:18+0200 [-] Log opened.
```

becomes:

```
2013-09-15 22:02:18+0200 [-] {"event": "Log opened.", "system": "-"}
```

There is obviously some redundancy here.
Also, I'm presuming that if you write out JSON logs, you're going to let something else parse them which makes the human-readable date entries more trouble than they're worth.

To get a clean log without timestamps and additional system fields (`[-]`), *structlog* comes with `structlog.twisted.PlainFileLogObserver` that writes only the plain message to a file and `structlog.twisted.plainJSONStdOutLogger` that composes it with the aforementioned `structlog.twisted.JSONLogObserverWrapper` and gives you a pure JSON log without any timestamps or other noise straight to [standard out]:

```console
$ twistd -n --logger structlog.twisted.plainJSONStdOutLogger web
{"event": "Log opened.", "system": "-"}
{"event": "twistd 13.1.0 (python 2.7.3) starting up.", "system": "-"}
{"event": "reactor class: twisted...EPollReactor.", "system": "-"}
{"event": "Site starting on 8080", "system": "-"}
{"event": "Starting factory <twisted.web.server.Site ...>", ...}
...
```

## Suggested Configuration

```python
import structlog

structlog.configure(
   processors=[
       structlog.processors.StackInfoRenderer(),
       structlog.twisted.JSONRenderer()
   ],
   context_class=dict,
   logger_factory=structlog.twisted.LoggerFactory(),
   wrapper_class=structlog.twisted.BoundLogger,
   cache_logger_on_first_use=True,
)
```

See also {doc}`logging-best-practices`.

[standard out]: https://en.wikipedia.org/wiki/Standard_out#Standard_output_.28stdout.29

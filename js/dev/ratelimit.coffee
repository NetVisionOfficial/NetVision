last_time = {}
calling = {}
call_after_interval = {}

# Rate limit function call and don't allow to run in parallel (until callback is called)
window.RateLimitCb = (interval, fn, args=[]) ->
    cb = ->  # Callback when function finished
        left = interval - (Date.now() - last_time[fn])  # Time life until next call
        # console.log "CB, left", left, "Calling:", calling[fn]
        if left <= 0  # No time left from rate limit interval
            delete last_time[fn]
            if calling[fn]  # Function called within interval
                RateLimitCb(interval, fn, calling[fn])
            delete calling[fn]
        else  # Time left from rate limit interval
            setTimeout (->
                delete last_time[fn]
                if calling[fn]  # Function called within interval
                    RateLimitCb(interval, fn, calling[fn])
                delete calling[fn]
            ), left
    if last_time[fn]  # Function called within interval
        calling[fn] = args  # Schedule call and update arguments
    else  # Not called within interval, call instantly
        last_time[fn] = Date.now()
        fn.apply(this, [cb, args...])

window.RateLimit = (interval, fn) ->
    if not calling[fn]
        call_after_interval[fn] = false
        fn() # First call is not delayed
        calling[fn] = setTimeout (->
            if call_after_interval[fn]
                fn()
            delete calling[fn]
            delete call_after_interval[fn]
        ), interval
    else # Called within iterval, delay the call
        call_after_interval[fn] = true

BASE = "https://dbinbox.com"

# see stripe #1675 for how to get currentScript if this doesn't work
scriptEl = document.currentScript

options = {}
for attr in scriptEl?.attributes
  match = attr?.name?.match(/^data-(.+)$/)
  if match && match[1]
    options[match[1]] = attr.value
# console.log(options)

# fix for IE7 and under missing querySelectorAll()
unless typeof document.querySelectorAll == 'function'
  try
    d = document
    s = d.createStyleSheet()

    d.querySelectorAll = (r, c, i, j, a) ->
      a = d.all
      c = []
      r = r.replace(/\[for\b/gi, '[htmlFor').split(',')
      i = r.length
      while i--
        s.addRule r[i], 'k:v'
        j = a.length
        while j--
          a[j].currentStyle.k and c.push(a[j])
        s.removeRule 0
      c
  catch err
    console.error("DBinbox error: couldn't insert querySelectorAll shim", err)

createiFrame = (url) ->
  i = document.createElement("iframe")

  i.setAttribute("src", url)
  i.setAttribute("horizontalscrolling", "no")
  i.setAttribute("allowtransparency", "true")
  i.setAttribute("verticalscrolling", "no")
  i.setAttribute("frameborder", "0")
  i.setAttribute("title", "dbinbox")
  i.setAttribute("scrolling", "no")
  i.setAttribute("tabindex", "0")
  i.setAttribute("width", "100%")

  i.style.width = "100%"
  i.overflow = "hidden"
  i.height = "400px"
  # i.height = "10px"
  i.border = "0"

  return i

timestamp = Date.now()

# replacing form inputs
if options
  if options.uploaders && options.page
    for el in document.querySelectorAll(options.uploaders)
      el.style.display = "none" unless options.debug
      # el.setAttribute('disabled', true)

      session_id = options.session || timestamp

      # input name OR id OR
      input_id = el.name || el.id || el.nodeName

      url = [BASE, options.page, session_id, input_id].join('/').replace(/\s/g, '')

      iframe = createiFrame(url + "?embed=true")
      el.parentNode.insertBefore(iframe, el);

      el.value = url

      iFrameResize({
        checkOrigin: false
        # enablePublicMethods: true
      }, iframe)
  else
    console.error('DBinbox.com error: missing script attributes data-uploaders or data-page')

# replace links with class dbinbox
window.processDbinboxEmbed = ->
  for a in document.querySelectorAll('.dbinbox')
    url = a.href
    url = url.replace("/embed/", "/")

    # add a ? to the url for params if it doesn't already have some
    url += "?" unless url.indexOf('?') != -1

    # set the embed param
    url += "&embed=true"

    iframe = createiFrame(url)
    a.parentNode.replaceChild(iframe, a)

  iFrameResize({
    checkOrigin: false
    # enablePublicMethods: true
    # messageCallback: (messageData) ->
    #   console.log "got message from iframe: ", messageData

  }, iframe)

processDbinboxEmbed()

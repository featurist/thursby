elementsIn (vdom) =
  if (vdom.children)
    [vdom].concat [c <- vdom.children || [], elementsIn(c)] ...
  else
    [vdom]

textIn (vdom) =
  if (vdom.text)
    vdom.text
  else if (vdom.children)
    [ c <- vdom.children, textIn (c) ].join('')
  else
    ''

classesIn (vdom) =
  if ((vdom.properties) && (vdom.properties.className))
    vdom.properties.className.split(' ')
  else
    []

click (vdom, text) =
  elements = [
    e <- elementsIn(vdom)
    (e.properties) && (e.properties.onclick :: Function) && (textIn(e) == text)
    e
  ]
  if (elements.length == 1)
    clickEvent = { preventDefault () = nil }
    elements.0.properties.onclick(clickEvent)
  else
    throw (@new Error "Expected one clickable element with '#(text)', found #(elements.length)")

dom (vdom) =
  {
    vdom = vdom
    click (text) = click (self.vdom, text)
    classes () = classesIn (self.vdom)
  }

module.exports = dom

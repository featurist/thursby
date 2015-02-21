render = require '../client/render'
stringify = require 'virtual-dom-stringify'
expect = require 'chai'.expect

describe 'render'

  model = nil

  beforeEach
    model := {
      firebaseChanged (refresh) =
        nil
    }

  describe 'with no authentication data'

    it 'renders a login button'
      vdom = render (model)
      html = stringify(vdom)
      expect(html).to.contain '<button class="login">Login with Github</button>'

  describe 'with authentication data'

    beforeEach
      model.authData = {
        uid = 'bobby-boulders'
        github = {
          displayName = 'Bobby Boulders'
          cachedUserProfile = {
            avatar_url = 'http://bobby.io/img'
          }
        }
      }

    it 'renders the authenticated users profile'
      vdom = render(model)
      html = stringify(vdom)
      expect(html).to.contain 'Bobby Boulders'
      expect(html).to.contain '<img src="http://bobby.io/img" class="avatar" />'

    describe 'when the layout is render-only'

      it 'adds the app-only class to the app element'
        model.layout = 'render-only'
        vdom = render(model)
        expect(vdom.properties.className).to.contain 'render-only'

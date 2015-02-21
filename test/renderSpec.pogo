render = require '../client/render'
stringify = require 'virtual-dom-stringify'
expect = require 'chai'.expect

describe 'render'

  describe 'with no authentication data'

    it 'renders a login button'
      vdom = render {}
      html = stringify(vdom)
      expect(html).to.contain '<button class="login">Login with Github</button>'

  describe 'with authentication data'

    it 'renders the authenticated users profile'
      model = {
        authData = {
          uid = 'bobby-boulders'
          github = {
            displayName = 'Bobby Boulders'
            cachedUserProfile = {
              avatar_url = 'http://bobby.io/img'
            }
          }
        }
        firebaseChanged (refresh) =
          nil
      }
      vdom = render(model)
      html = stringify(vdom)
      expect(html).to.contain 'Bobby Boulders'
      expect(html).to.contain '<img src="http://bobby.io/img" class="avatar" />'

require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  let(:uid) { request.env['omniauth.auth']['uid'] }

  before do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:auth0]
  end

  describe 'GET callback' do
    context 'WHEN no user found with the given email' do
      it 'creates a user if not found' do
        expect { get 'callback' }.to change(User, :count).to(1)
        expect(User.first.uid).to eq(uid)
      end

      it 'sets the session[:user_id]' do
        get 'callback'

        expect(session[:user_id]).to be_present
      end

      it 'redirects to settings topics page' do
        get 'callback'

        expect(response).to redirect_to(settings_topics_path)
      end
    end

    context 'WHEN user with email exists' do
      let!(:user) { Fabricate(:user, uid: uid) }
      let(:token) { request.env['omniauth.auth'].dig('credentials', 'token') }

      it 'updates the token of the user' do
        expect { get 'callback' }.to change { user.reload.token }.to(token)
      end

      context 'AND user did not select topics' do
        it 'redirects to settings topics page' do
          user.user_topics.destroy_all
          get 'callback'

          expect(response).to redirect_to(settings_topics_path)
        end
      end

      context 'AND user selected topics already' do
        let!(:topics) { Fabricate.times(3, :topic) }
        let!(:user_topics) { topics.map { |topic| Fabricate(:user_topic, user: user, topic: topic) } }

        it 'redirects to dashboard page' do
          get 'callback'

          expect(response).to redirect_to(dashboard_path)
        end
      end
    end
  end

  describe 'GET logout' do
    it 'redirects to logout url' do
      expect(Rails.application).to receive(:credentials)
        .and_return({ test: { auth0: { client_id: 'cid',
                                       domain: 'domain' } } })
      params = {
        returnTo: root_url,
        client_id: 'cid'
      }
      logout_url = 'https://domain/logout'
      expect(URI::HTTPS).to receive(:build)
        .with(host: 'domain', path: '/v2/logout', query: params.to_query)
        .and_return(logout_url)
      get 'logout'
      expect(response).to redirect_to(logout_url)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoginController, type: :controller do
  # Create a simple user fosr session-based tests
  let(:user) do
    User.create!(
      uid:        '12345',
      email:      'test@example.com',
      first_name: 'Test',
      last_name:  'User',
      provider:   User.providers[:google_oauth2]
    )
  end

  # Mock auth hashes for OAuth testing
  let(:mock_auth_hash) do
    {
      'provider' => 'google_oauth2',
      'uid'      => '123456',
      'info'     => {
        'first_name' => 'John',
        'last_name'  => 'Doe',
        'email'      => 'john@example.com'
      }
    }
  end

  let(:mock_github_auth_hash) do
    {
      'provider' => 'github',
      'uid'      => '789012',
      'info'     => {
        'name'  => 'John Doe',
        'email' => 'john@example.com'
      }
    }
  end

  describe 'GET #login' do
    context 'when user is not logged in' do
      it 'renders the login page' do
        get :login
        expect(response).to render_template(:login)
      end
    end

    context 'when user is already logged in' do
      before { session[:current_user_id] = user.id }

      it 'redirects to user profile with notice' do
        get :login
        expect(response).to redirect_to(user_profile_path)
        expect(flash[:notice]).to eq('You are already logged in. Logout to switch accounts.')
      end
    end
  end

  describe 'GET #logout' do
    before { session[:current_user_id] = user.id }

    it 'clears the session and redirects to root path' do
      get :logout
      expect(session[:current_user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('You have successfully logged out.')
    end
  end

  describe 'GET #google_oauth2' do
    before do
      request.env['omniauth.auth'] = mock_auth_hash
    end

    context 'when user does not exist' do
      it 'creates a new user and sets session' do
        expect do
          get :google_oauth2
        end.to change(User, :count).by(1)
      end

      it 'sets the correct attributes for the new user' do
        get :google_oauth2
        new_user = User.last
        expect(new_user.provider).to eq('google_oauth2')
        expect(new_user.uid).to eq('123456')
        expect(new_user.first_name).to eq('John')
      end

      it 'sets the correct attributes for the new user pt 2' do
        get :google_oauth2
        new_user = User.last
        expect(new_user.last_name).to eq('Doe')
        expect(new_user.email).to eq('john@example.com')
        expect(session[:current_user_id]).to eq(new_user.id)
      end

      it 'redirects to root_url by default' do
        get :google_oauth2
        expect(response).to redirect_to(root_url)
      end

      it 'redirects to stored destination_after_login if present' do
        session[:destination_after_login] = '/custom_path'
        get :google_oauth2
        expect(response).to redirect_to('/custom_path')
        expect(session[:destination_after_login]).to be_nil
      end
    end

    context 'when user already exists' do
      let!(:existing_user) do
        User.create!(
          provider:   'google_oauth2',
          uid:        '123456',
          first_name: 'John',
          last_name:  'Doe',
          email:      'john@example.com'
        )
      end

      it 'does not create a new user' do
        expect do
          get :google_oauth2
        end.not_to change(User, :count)
      end

      it 'sets the session with existing user id' do
        get :google_oauth2
        expect(session[:current_user_id]).to eq(existing_user.id)
      end
    end
  end

  describe 'GET #github' do
    before do
      request.env['omniauth.auth'] = mock_github_auth_hash
    end

    context 'when user does not exist' do
      it 'creates a new user and sets session' do
        expect do
          get :github
        end.to change(User, :count).by(1)
      end

      it 'sets correct attributes' do
        get :github
        new_user = User.last
        expect(new_user.provider).to eq('github')
        expect(new_user.uid).to eq('789012')
        expect(new_user.first_name).to eq('John')
      end

      it 'sets correct attributes pt 2' do
        get :github
        new_user = User.last
        expect(new_user.last_name).to eq('Doe')
        expect(new_user.email).to eq('john@example.com')
        expect(session[:current_user_id]).to eq(new_user.id)
      end
    end

    context 'when github user has no name' do
      before do
        mock_github_auth_hash['info']['name'] = nil
      end

      it 'creates user with default name' do
        get :github
        new_user = User.last
        expect(new_user.first_name).to eq('Anon')
        expect(new_user.last_name).to eq('User')
      end
    end

    context 'when user already exists' do
      let!(:existing_user) do
        User.create!(
          provider:   'github',
          uid:        '789012',
          first_name: 'John',
          last_name:  'Doe',
          email:      'john@example.com'
        )
      end

      it 'does not create a new user' do
        expect do
          get :github
        end.not_to change(User, :count)
      end

      it 'sets the session with existing user id' do
        get :github
        expect(session[:current_user_id]).to eq(existing_user.id)
      end
    end
  end
end

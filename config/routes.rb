Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :rails_health_check

  get "analysis", to: "analyses#show", as: :analysis

  resources :searches, only: %i[create show] do
    get :autocomplete, on: :collection
  end

  resources :keys, only: [] do
    resources :chords, only: %i[index show] do
      get :staff, on: :member
      resources :voicings, only: %i[index show]
    end

    resources :progressions, only: %i[index show] do
      get :staff, on: :member
    end

    resources :note_sequences, path: 'notes', only: [:show] do
      get :staff, on: :member
    end

    resources :chord_sequences, path: 'chord-sequences', only: [:show] do
      get :staff, on: :member
    end

    resources :chord_note_sequences, path: 'chord-notes', only: [:show] do
      get :staff, on: :member
    end

    resources :scales, only: %i[index show] do
      resources :modes, only: %i[index show]
    end
  end

  resources :chords, only: %i[index show] do
    get :staff, on: :member
    resources :voicings, only: %i[index show]
  end

  resources :scales, only: %i[index show] do
    get :staff, on: :member

    resources :modes, only: %i[index show] do
      get :staff, on: :member
    end
  end

  resources :progressions, only: %i[index show] do
    get :staff, on: :member
  end

  resources :note_sequences, path: 'notes', only: [:show] do
    get :staff, on: :member
  end

  resources :chord_sequences, path: 'chord-sequences', only: [:show] do
    get :staff, on: :member
  end

  resources :chord_note_sequences, path: 'chord-notes', only: [:show] do
    get :staff, on: :member
  end

  root to: 'dashboards#show'
end

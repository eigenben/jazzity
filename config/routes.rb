Jazzity::Application.routes.draw do
  get '/contribute', to: redirect('https://github.com/rubiety/jazzity/wiki/Contributions')

  resources :searches, only: %i[create show] do
    get :autocomplete, on: :collection
  end

  resources :keys, only: [:show] do
    resources :chord_qualities, only: %i[index show]
    resources :chords, only: %i[index show] do
      get :staff, on: :member
      resources :voicings, only: %i[index show]
    end

    resources :progressions, only: %i[index show] do
      get :staff, on: :member
    end

    resources :note_sequences, path: 'notes', only: %i[index show] do
      get :staff, on: :member
    end

    resources :chord_sequences, path: 'chord-sequences', only: [:show] do
      get :staff, on: :member
    end

    resources :chord_note_sequences, path: 'chord-notes', only: %i[index show] do
      get :staff, on: :member
    end

    resources :scales, only: %i[index show] do
      resources :modes, only: %i[index show]
    end
  end

  resources :chord_qualities, only: %i[index show]
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

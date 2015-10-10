require 'rails_helper'

describe ReviewsController do
  let(:user)    { Fabricate(:user) }
  let(:company) { Fabricate(:company) }

  describe 'GET #new' do
    context 'when user is logged in' do
      before(:example) { session[:user_id] = user.id }

      it 'assigns @review' do
        get :new, user_id: user.id, company_id: company.id
        expect(assigns[:review]).to be_a_new(Review)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login path' do
        get :new, user_id: user.id, company_id: company.id
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is logged in' do
      before(:example) { session[:user_id] = user.id }

      it 'redirects to users my reviews page' do
        post :create, user_id: user.id, company_id: company.id, review: Fabricate.attributes_for(:review)
        expect(response).to redirect_to(reviews_user_path(user))
      end

      it 'creates new review' do
        post :create, user_id: user.id, company_id: company.id, review: Fabricate.attributes_for(:review)
        expect(Review.all.count).to eq(1)
        expect(flash[:success]).to eq('You have successfully created Review.')
      end

      it 'renders new template if there are invalid params' do
        post :create, user_id: user.id, company_id: company.id, review: Fabricate.attributes_for(:review, content: '')
        expect(Review.all.count).to eq(0)
        expect(flash[:danger]).to eq('You have to mark star and write a comment up to 300 characters!')
      end

      it 'user san create only one review per company'
      it 'displays danger flash message that user has already reviewed this company'

    end

    context 'when user is not logged in' do
      it 'redirects to login page'
      it 'does not create new review'
    end
  end

  describe 'GET #edit' do
    let(:user)    { Fabricate(:user) }
    let(:owner)   { Fabricate(:user, role: 'owner') }
    let(:company) { Fabricate(:company, owner: owner) }
    let(:review)  { Fabricate(:review, company: company, user: owner) }

    context 'when user is logged in' do
      it 'assigns @reivew' do
        session[:user_id] = user.id
        get :edit, user_id: owner.id, company_id: company.id, id: review.id
        expect(assigns[:review]).to be_a(Review)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :edit, user_id: owner.id, company_id: company.id, id: review.id
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:user)    { Fabricate(:user) }
    let(:owner)   { Fabricate(:user, role: 'owner') }
    let(:company) { Fabricate(:company, owner: owner) }
    let(:review)  { Fabricate(:review, company: company, user: owner) }

    context 'when user is logged in' do
      it 'redirects_to user reviews page' do
        session[:user_id] = user.id
        get :update, user_id: user.id, company_id: company.id, id: review.id, review: Fabricate.attributes_for(:review)
        expect(response).to redirect_to(reviews_user_path(user))
      end

      it 'updates review' do
        session[:user_id] = user.id
        get :update, user_id: user.id, company_id: company.id, id: review.id, review: Fabricate.attributes_for(:review, content: 'Changed!!!')
        expect(review.reload.content).to eq('Changed!!!')
      end

      it 'renders edit page params do not validate' do
        session[:user_id] = user.id
        get :update, user_id: user.id, company_id: company.id, id: review.id, review: Fabricate.attributes_for(:review, content: '')
        expect(response).to render_template(:edit)
      end

      it 'cannot update other user review' do
        session[:user_id] = user.id
        get :update, user_id: owner.id, company_id: company.id, id: review.id, review: Fabricate.attributes_for(:review, content: 'Heker changed this review!')
        expect(review.reload.content).not_to eq('Heker changed this review!')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login path' do
        get :update, user_id: owner.id, company_id: company.id, id: review.id, review: Fabricate.attributes_for(:review, content: 'Heker changed this review!')
        expect(response).to redirect_to(login_path)
      end

      it 'does not update the review' do
        review
        get :update, user_id: user.id, company_id: company.id, id: review.id, review: Fabricate.attributes_for(:review, content: 'Changed!!!')
        expect(review.reload.content).not_to eq('Changed!!!')
      end
    end
  end

  describe 'DETLETE #destroy' do
    let(:user)    { Fabricate(:user) }
    let(:owner)   { Fabricate(:user, role: 'owner') }
    let(:company) { Fabricate(:company, owner: owner) }
    let(:review)  { Fabricate(:review, company: company, user: owner) }

    context 'when user is logged in' do
      it 'redirects to user reviews page' do
        session[:user_id] = user.id
        delete :destroy, user_id: user.id, company_id: company.id, id: review.id
        expect(response).to redirect_to(reviews_user_path(user))
      end

      it 'deletes the users review' do
        session[:user_id] = user.id
        delete :destroy, user_id: user.id, company_id: company.id, id: review.id
        expect(Review.all.count).to eq(0)
      end

      it 'cannot delete other users review' do
        session[:user_id] = user.id
        delete :destroy, user_id: owner.id, company_id: company.id, id: review.id
        expect(Review.all.count).to eq(1)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        delete :destroy, user_id: owner.id, company_id: company.id, id: review.id
        expect(response).to redirect_to(login_path)
      end

      it 'does not delete review' do
        delete :destroy, user_id: user.id, company_id: company.id, id: review.id
        expect(Review.all.count).to eq(1)
      end
    end
  end

  describe 'GET #listed_companies' do
    let(:user) { Fabricate(:user) }

    context 'when user is logged in' do
      let(:company)   { Fabricate(:company) }
      let(:company_1) { Fabricate(:company) }

      it 'assigns @companies' do
        session[:user_id] = user.id
        get :listed_companies
        expect(assigns[:companies]).to match_array([company, company_1])
      end

      it 'orders companies by the review count'
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :listed_companies
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'GET #recent' do

    context 'when user is logged in' do
      it 'renders the home page' do
        session[:user_id] = Fabricate(:user).id
        get :recent
        expect(response).to render_template(:recent)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :recent
        expect(response).to render_template(:recent)
      end

    end

  end

end
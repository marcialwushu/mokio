require 'spec_helper'

describe Mokio::Backend::MenusController do
  # include Devise::TestHelpers
  render_views
  # This should return the minimal set of attributes required to create a valid
  # Menu. As you add validations to Menu, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {:name => "Tralalala", :lang_id => 1, :parent_id => 1  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MenusController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before :each do
    request.env["HTTP_REFERER"] = backend_menus_path
  end

  before :all do
    Menu.delete_all
    Lang.delete_all
    Lang.create(:name => 'polish', :shortname => 'pl', :id => 1)
    Menu.new(:name => 'pl', :id => 1, :lang_id => 1, :editable => false).save(:validate => false)
    Menu.new(:name => 'Stopka', :lang_id => 1, :parent_id => 1, :editable => false).save(:validate => false)
  end

  # describe "GET index" do
  #   it "@menus contains arranged tree" do
  #     get :index, {}, valid_session
  #     assigns(:menus).keys[0].name.should eq("pl")
  #   end
  # end

  describe "GET new" do
    it "assigns a new backend_menu as @menu" do
      get :new, {}, valid_session
      assigns(:menu).should be_a_new(Menu)
    end
    it "@parent_tree is set for valid lang_id" do
      get :new, {}, valid_session
      assigns(:menu).parent_tree[0].name.should eq("pl") #todo - more than one language
    end
  end

  describe "GET edit" do
    it "assigns the requested backend_menu as @menu" do
      menu = Menu.create! valid_attributes
      get :edit, {:id => menu.to_param}, valid_session
      assigns(:menu).should eq(menu)
    end

    it "@parent_tree is set for valid lang_id" do
      menu = Menu.create! valid_attributes
      get :edit, {:id => menu.to_param}, valid_session
      assigns(:menu).parent_tree[0].name.should eq("pl")
    end

    it "@parent_tree is set for deep element" do
      menu = Menu.find_by('ancestry is not NULL')
      get :edit, {:id => menu.to_param}, valid_session
      assigns(:menu).parent_tree[0].name.should eq(menu.parent.name)
    end

    it "@parent_tree does not contain self" do
      menu = Menu.find_by('ancestry is not NULL')
      get :edit, {:id => menu.to_param}, valid_session
      assigns(:menu).parent_tree.should_not include(menu)
    end

    it "gets article list for valid lang PL" do
      menu = Menu.create! valid_attributes
      get :edit, {:id => menu.to_param}, valid_session
      assigns(:menu).available_contents.to_set.superset?(Article.where(:lang_id => menu.lang_id).to_set).should be_true
    end

    it "assigns a list of available (not selected) modules to available_modules_by_pos (with lang_id = 1)" do
      mod_pos = FactoryGirl.create(:module_position)
      stat_module = FactoryGirl.create(:static_module)
      stat_module.module_positions = [mod_pos]
      stat_module.lang_id = 1
      stat_module.save
      av_module = AvailableModule.where(static_module_id: stat_module.id, module_position_id: mod_pos.id).first
      menu = FactoryGirl.create(:menu)
      get :edit, {:id => menu.to_param}, valid_session 
      (assigns(:menu).available_modules_by_pos[mod_pos.id].include?(av_module)).should be_true
    end
   
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Menu" do
        expect {
          post :create, {:menu => valid_attributes}, valid_session
        }.to change(Menu, :count).by(1)
      end

      
      it "assigns a newly created backend_menu as @menu" do
        post :create, {:menu => valid_attributes}, valid_session
        assigns(:menu).should be_a(Menu)
        assigns(:menu).should be_persisted
      end

      it "redirects to the created backend_menu" do
        post :create, {:menu => valid_attributes}, valid_session
        response.should redirect_to(backend_menus_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved menu as @menu" do
        # Trigger the behavior that occurs when invalid params are submitted
        Menu.any_instance.stub(:save).and_return(false)
        post :create, {:menu => {  }}, valid_session
        assigns(:menu).should be_a_new(Menu)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        @menu = Menu.any_instance.stub(:save).and_return(false)
        post :create, {:menu => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested backend_menu" do
        menu = Menu.create! valid_attributes
        put :update, {:id => menu.to_param, :menu => { :name => "bla" }}, valid_session
        @new_menu = Menu.find(menu.id)
        @new_menu.name.should eq("bla") #_receive(:update) #.with({ :name => "bla" })
        
      end

      it "for not editable menu update is not performed" do
        menu = Menu.where(editable: false).first
        expect(menu.editable).to be_false
        put :update, {:id => menu.to_param, :menu => {:name => 'New name'}}, valid_session
        @new_menu = Menu.find(menu.id)
        @new_menu.name.should eq(menu.name)
      end

      it "assigns the requested backend_menu as @menu" do
        menu = Menu.create! valid_attributes
        put :update, {:id => menu.to_param, :menu => valid_attributes}, valid_session
        assigns(:menu).should eq(menu)
      end

      it "redirects to the backend_menu" do
        menu = Menu.create! valid_attributes
        put :update, {:id => menu.to_param, :menu => valid_attributes}, valid_session
        response.should redirect_to(backend_menus_path)
      end
    end

    describe "with invalid params" do
      it "assigns the backend_menu as @menu" do
        menu = Menu.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Menu.any_instance.stub(:save).and_return(false)
        put :update, {:id => menu.to_param, :menu => {  }}, valid_session
        assigns(:menu).should eq(menu)
      end

      it "re-renders the 'edit' template" do
        menu = Menu.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Menu.any_instance.stub(:save).and_return(false)
        put :update, {:id => menu.to_param, :menu => {  }}, valid_session
        response.should render_template("edit")
      end

      it "contents are not removed" do
        menu = Menu.create! valid_attributes
        content = FactoryGirl.create(:content)
        menu.contents << content
        menu.save
        # Trigger the behavior that occurs when invalid params are submitted
        menu.stub(:save).and_return(false)
        menu.stub_chain(:errors, :empty?).and_return(false)
        put :update, {:id => menu.to_param, :menu => {:name => '' }}, valid_session
        assigns(:menu).contents.should_not be_empty
      end

      it "selected modules are not removed" do
        mod_pos = FactoryGirl.create(:module_position)
        stat_module = FactoryGirl.create(:static_module)
        stat_module.module_positions = [mod_pos]
        stat_module.lang_id = 1
        stat_module.save
        menu = Menu.create! valid_attributes
        first_module = menu.available_modules_by_pos[mod_pos.id][0]
        menu.available_modules << first_module
        menu.save
        # Trigger the behavior that occurs when invalid params are submitted
        menu.stub(:save).and_return(false)
        menu.stub_chain(:errors, :empty?).and_return(false)
        put :update, {:id => menu.to_param, :menu => {:name => '' }}, valid_session
        assigns(:menu).available_modules.should_not be_empty
      end
   end

    it "contents order is saved after update" do
      content1 = Article.create(:title => 'Bla')
      content2 = Article.create(:title => 'ZZZZ')
      menu = Menu.create! valid_attributes
      put :update, {:id => menu.to_param, :menu => {:content_ids => [content2.id, content1.id] }}, valid_session
      menu.reload
      expect(menu.contents.first).to eq(content2)
    end

    it "selected modules order is saved after update" do
      mod_pos = FactoryGirl.create(:module_position)
      stat_module = FactoryGirl.create(:static_module)
      stat_module.module_positions = [mod_pos]
      stat_module.lang_id = 1
      stat_module.save
      stat_module1 = FactoryGirl.create(:static_module)
      stat_module1.module_positions = [mod_pos]
      stat_module1.lang_id = 1
      stat_module1.save
      menu = Menu.create! valid_attributes
      first_module_id = menu.available_modules_by_pos[mod_pos.id][0].id
      put :update, {:id => menu.to_param, :menu => {:available_module_ids => {mod_pos.id.to_s => [menu.available_modules_by_pos[mod_pos.id][0].id, menu.available_modules_by_pos[mod_pos.id][1].id] }}}, valid_session
      (assigns(:menu).available_modules.first.id).should eq(first_module_id)
    end


    it "contents are cleared properly" do
      content = Article.create(:title => 'Bla')
      menu = Menu.create! valid_attributes
      menu.contents << content
      menu.save
      expect(menu.contents.length).to eq(1)
      put :update, {:id => menu.to_param, :menu => {}}, valid_session
      (assigns(:menu).contents).should be_empty
    end

    it "selected modules are cleared properly" do
      mod_pos = FactoryGirl.create(:module_position)
      stat_module = FactoryGirl.create(:static_module)
      stat_module.module_positions = [mod_pos]
      stat_module.lang_id = 1
      stat_module.save
      menu = Menu.create! valid_attributes
      first_module = menu.available_modules_by_pos[mod_pos.id][0]
      menu.available_modules << first_module
      menu.save
      expect(menu.reload.available_modules.length).to eq(1)
      put :update, {:id => menu.to_param, :menu => {}}, valid_session
      (assigns(:menu).available_modules).should be_empty
    end


  end

  describe "DELETE destroy" do
    it "destroys the requested menu when deletable" do
      menu = Menu.create! valid_attributes.merge(:deletable => true)
      @obj = menu
      expect {
        delete :destroy, {:id => menu.to_param}, valid_session
      }.to change(Menu, :count).by(-1)
    end

    it "redirects to the backend_menus list" do
      menu = Menu.create! valid_attributes
      delete :destroy, {:id => menu.to_param}, valid_session
      response.should redirect_to(backend_menus_url)

    end

    it "not destroys the requested menu when not deletable" do
      menu = Menu.create! valid_attributes.merge(:deletable => false)
      expect {
        delete :destroy, {:id => menu.to_param}, valid_session
      }.to change(Menu, :count).by(0)
    end

    it "redirects to the backend_menus list when not deletable" do
      menu = Menu.create! valid_attributes.merge(:deletable => false)
      delete :destroy, {:id => menu.to_param}, valid_session
      response.should redirect_to(backend_menus_url)

    end


    it "destroys the requested menu" do
      menu = Menu.create! valid_attributes.merge(:deletable => true)
      child_del = Menu.create! valid_attributes.merge(:deletable => false, :parent => menu)
      child_not_del = Menu.create! valid_attributes.merge(:deletable => true, :parent => menu)
      expect {
        delete :destroy, {:id => menu.to_param}, valid_session
      }.to change(Menu, :count).by(-1)

    end

    it "attaches children to parent node" do
      top_parent = Menu.create! valid_attributes.merge(:deletable => true)
      menu = Menu.create! valid_attributes.merge(:deletable => true, :parent => top_parent)
      child_del = Menu.create! valid_attributes.merge(:deletable => false, :parent => menu)
      child_not_del = Menu.create! valid_attributes.merge(:deletable => true, :parent => menu)
      delete :destroy, {:id => menu.to_param}, valid_session
      expect top_parent.children.should include(child_del) 
    end
  end

  describe "update_menu_breadcrumps" do
    subject {controller.update_menu_breadcrumps}
    it "updates menu_breadcrumps element" do
      menu = Menu.find_by(:name => "Stopka")
      # expect(
      #   (xhr :get, :update_menu_breadcrumps, {:menu_id => menu.id}, valid_session).body
      # ).to match('.*pl.*Stopka.*') 
      pending
    end
  end

  describe "lang_changed" do
    subject {controller.lang_changed}
    it "updates menu_parent options" do
      menu = Menu.find_by(:name => "Stopka")
      body = (xhr :get, :lang_changed, {:menu_id => menu.id, :lang_id => 1}, valid_session).body
      expect(body).to match('.*pl.*') 
    end

  end

  describe "sort" do
    before(:each) {
      @menu_hash = {}
      @menu_fake_pl = Menu.create! valid_attributes.merge(:parent => nil, :lang_id => 1)
      @menu_fake_top = Menu.create! valid_attributes.merge(:parent_id => @menu_fake_pl.id, :lang_id => 1)
      @menu = Menu.create! valid_attributes.merge(:parent_id => @menu_fake_top.id, :lang_id => 1)
      @menu_child = Menu.create! valid_attributes.merge(:parent_id => @menu.id, :lang_id => 1)
      @menu_grandchild1 = Menu.create! valid_attributes.merge(:parent_id => @menu_child.id, :seq => 1, :lang_id => 1)
      @menu_grandchild2 = Menu.create! valid_attributes.merge(:parent_id => @menu_child.id, :seq => 2, :lang_id => 1)
      @menu_grandchild3 = Menu.create! valid_attributes.merge(:parent_id => @menu_child.id, :seq => 3, :lang_id => 1)
      @potential_parent = Menu.create! valid_attributes
      @menu_hash[@menu.id] = @menu_fake_top.id
      @menu_hash[@menu_child.id] = @menu_child.parent_id
    }


    it "changes the order of elements" do
      @menu_hash[@menu_grandchild2.id] = @menu_grandchild2.parent_id
      @menu_hash[@menu_grandchild1.id] = @menu_grandchild1.parent_id
      xhr :get, :sort, {:menu => @menu_hash}, valid_session 
      expect(@menu_grandchild2.reload.seq).to eq(1)
      expect(@menu_grandchild1.reload.seq).to eq(2)
    end

    it "changes parent of an element" do
      @menu_hash[@menu_grandchild1.id] = @menu_child.parent_id
      @menu_hash[@menu_grandchild2.id] = @menu_grandchild2.parent_id
      xhr :get, :sort, {:menu => @menu_hash}, valid_session
      expect(@menu_grandchild1.reload.parent_id).to eq(@menu_child.parent_id)
      expect(@menu_grandchild2.reload.parent_id).to eq(@menu_grandchild2.parent_id)
    end

    it "does not allow new ROOT nodes" do
      @menu_hash[@menu_grandchild1.id] = "null"
      xhr :get, :sort, {:menu => @menu_hash}, valid_session
      @menu_grandchild1.reload
      expect(@menu_grandchild1.root?).to be_false
    end

    it "sets proper parent for 'root' nodes based on elt's lang" do
      @menu_hash[@menu_grandchild3.id] = "null"
      xhr :get, :sort, {:menu => @menu_hash}, valid_session
      expect(@menu_child.reload.root.id).to eq(@menu_grandchild3.root.id)
      expect(@menu_child.reload.root.id).not_to eq(@menu_child.parent.id)
      expect(@menu_child.root.lang.id).to eq(@menu_child.lang.id)
      
    end

    it "allows changes of ROOT nodes order" do 
      @menu2 = Menu.create! valid_attributes.merge(:parent => nil, :lang_id => 1)
      @menu3 = Menu.create! valid_attributes.merge(:parent_id => nil, :lang_id => 1) 
      @menu_hash[@menu2.id] = "null"
      @menu_hash[@menu3.id] = "null"
      
      xhr :get, :sort, {:menu => @menu_hash}, valid_session 
      expect(@menu3.reload.seq).to eq(@menu2.reload.seq + 1)

    end

    it "doesn't allow loops in the tree" do 
      @menu_hash[@menu_child.id] = @menu_grandchild1.id
      xhr :get, :sort, {:menu => @menu_hash}, valid_session
      @menu_child.reload
      expect(@menu_child.parent_id).to eq(@menu.id)
    end

    it "changes lang_id when parent of menu belongs to different lang tree" do
      @root_en = FactoryGirl.create(:root_en)
      @menu_grandchild1.lang_id = 1
      @menu_grandchild1.save
      @menu_hash[@menu_grandchild1.id] = @root_en.id
      expect(@menu_grandchild1.lang_id).not_to eq(@root_en.lang_id)
      xhr :get, :sort, {:menu => @menu_hash}, valid_session 
      expect(@menu_grandchild1.reload.lang_id).to eq(@root_en.lang_id)
    end
  end
end

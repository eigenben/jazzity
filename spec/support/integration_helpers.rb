module IntegrationHelpers
  def navigate_to(name)
    within("nav[aria-label=Sections]") do
      click_on name
    end
  end
end

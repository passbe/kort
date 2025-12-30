module FormHelper
  def label_css
    "block text-sm/6 font-medium text-gray-200"
  end

  def input_css
    "block w-full text-gray-200 rounded-md bg-neutral-700 text-base px-3 py-2 outline-1 -outline-offset-1 outline-neutral-600 placeholder:text-gray-400"
  end

  def checkbox_css
    "bg-neutral-700 accent-sky-600"
  end

  def radio_css
    "bg-neutral-700 accent-sky-600"
  end

  def select_css
    "col-start-1 row-start-1 block w-full appearance-none rounded-md bg-neutral-700 text-base text-gray-200 pl-3 pr-8 py-2 outline-1 -outline-offset-1 outline-neutral-600 placeholder:text-gray-400"
  end
end

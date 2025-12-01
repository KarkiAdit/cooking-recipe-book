//
//  Receipe.swift
//  CookBook
//
//

import Foundation

struct Receipe: Identifiable, Codable {
    let id: String
    let image: String
    let name: String
    let instructions: String
    let time: Int
    
    init(id: String, name: String, image: String, instructions: String, time: Int) {
        self.id = id
        self.name = name
        self.image = image
        self.instructions = instructions
        self.time = time
    }
    
}

extension Receipe {
    
    static var mockReceipes = [
        Receipe(id: UUID().uuidString, name: "Steak and Potatoes", image: "beef", instructions: "To prepare a classic steak and potatoes meal, start by preheating your oven to 400°F for the potatoes. Wash and cut the potatoes into wedges, toss them with olive oil, salt, pepper, and your choice of herbs like rosemary or thyme. Spread them on a baking sheet and roast until golden and crispy, about 25-30 minutes, turning halfway through. Meanwhile, take your steak out of the fridge and let it come to room temperature for about 20 minutes. Season it generously with salt and pepper. Heat a cast-iron skillet over high heat and add a splash of oil. Sear the steak for about 3-4 minutes on each side for medium-rare, or longer depending on the thickness and your preference. Let the steak rest for a few minutes before slicing. Serve with the roasted potatoes and a side of steamed vegetables or a fresh salad for a complete meal.", time: 40),
        Receipe(id: UUID().uuidString, name: "Roast Chicken", image: "chicken", instructions: "To prepare a delicious roast chicken, begin by preheating your oven to 375°F (190°C). Clean the chicken by removing any giblets and pat it dry with paper towels. Rub the entire surface of the chicken with olive oil and season generously inside and out with salt, pepper, and herbs like rosemary, thyme, and sage. Optionally, stuff the cavity with halved lemons and garlic cloves to enhance the flavor. Place the chicken breast-side up in a roasting pan. Tuck the wing tips under the body and tie the legs together with kitchen twine. Roast in the oven for about 20 minutes per pound, or until the internal temperature reaches 165°F (74°C) and the juices run clear. Let the chicken rest for 10 minutes before carving to allow the juices to redistribute. Serve with roasted vegetables or a light salad for a hearty, satisfying meal.", time: 50),
        Receipe(id: UUID().uuidString, name: "Lasagna", image: "lasagna", instructions: "To prepare a classic lasagna, start by preheating your oven to 375°F (190°C). First, prepare the meat sauce by sautéing chopped onions and garlic in olive oil until translucent. Add ground beef or a mix of beef and pork, and cook until browned. Stir in a can of crushed tomatoes, basil, oregano, salt, and pepper, and let it simmer for about 20 minutes. In a separate bowl, mix ricotta cheese with an egg, grated Parmesan, and chopped parsley. To assemble the lasagna, spread a layer of meat sauce in a baking dish, followed by a layer of lasagna noodles (no need to boil if using oven-ready noodles). Spread a layer of the ricotta mixture over the noodles, and sprinkle with shredded mozzarella. Repeat the layers until all ingredients are used, finishing with a generous layer of cheese. Cover with foil and bake for 25 minutes, then remove the foil and bake for another 25 minutes until the top is bubbly and golden. Allow it to rest for 15 minutes before slicing to help the layers set. Serve warm with a side of garlic bread or a green salad.", time: 60),
        Receipe(id: UUID().uuidString, name: "Omelette", image: "omelette", instructions: "To prepare a basic omelette, start by beating 2-3 eggs in a bowl with a pinch of salt and pepper. Heat a non-stick skillet over medium heat and add a small amount of butter or oil. Once the butter is melted or the oil is hot, pour in the eggs. As the eggs begin to set, gently lift the edges with a spatula, allowing the uncooked eggs to flow underneath. When the eggs are mostly set but still slightly runny on top, add your chosen fillings—such as cheese, diced vegetables, herbs, or cooked meats—on one half of the omelette. Carefully fold the other half over the fillings. Let it cook for another minute or so, until the cheese is melted and the omelette is cooked through. Slide the omelette onto a plate and serve immediately. Enjoy a customizable and quick meal that's perfect for breakfast or a light dinner.", time: 10),
        Receipe(id: UUID().uuidString, name: "Pasta", image: "pasta", instructions: "To prepare pasta, start by bringing a large pot of salted water to a boil. Choose your pasta shape and add it to the boiling water, stirring occasionally to prevent sticking. Follow the cooking time suggested on the package, typically between 8 to 12 minutes, until the pasta is al dente, which means it should be tender but still firm to the bite. While the pasta cooks, you can prepare a sauce of your choice, such as a quick garlic and olive oil sauté, a creamy Alfredo, or a hearty marinara. Once the pasta is cooked, drain it, reserving a cup of the pasta water. Return the pasta to the pot and mix it with your sauce, adding a bit of the reserved pasta water to help the sauce cling to the pasta smoothly. Serve immediately with a sprinkle of grated Parmesan cheese and fresh herbs for an extra touch of flavor.", time: 20),
        Receipe(id: UUID().uuidString, name: "Pizza", image: "pizza", instructions: "To prepare homemade pizza, begin by preheating your oven to its highest setting, typically between 450°F to 500°F (232°C to 260°C). If you have a pizza stone, place it in the oven to heat up. Roll out your pizza dough on a floured surface to your desired thickness. Transfer the dough to a pizza peel or an inverted baking sheet, dusted with flour or cornmeal to prevent sticking. Spread a thin layer of pizza sauce over the dough, leaving a small border for the crust. Top with your favorite ingredients—mozzarella cheese, pepperoni, vegetables, or whatever you like. If using a pizza stone, carefully slide the pizza onto the hot stone in the oven; otherwise, place the baking sheet in the oven. Bake for about 10-15 minutes, or until the crust is golden and the cheese is bubbly and slightly browned. Remove from the oven, let cool for a few minutes, then slice and serve hot. Enjoy creating a variety of pizzas with different toppings for a fun and customizable meal.", time: 30),
        Receipe(id: UUID().uuidString, name: "Salad", image: "salad", instructions: "To prepare a fresh and vibrant salad, begin by choosing a variety of greens such as romaine, arugula, spinach, or mixed baby leaves as your base. Wash and dry the greens thoroughly. In a large bowl, add the cleaned greens along with a mix of colorful vegetables like sliced cucumbers, cherry tomatoes, red onions, and bell peppers. For added texture and flavor, incorporate ingredients such as nuts, seeds, crumbled cheese, or fresh herbs. To dress the salad, whisk together a simple vinaigrette of olive oil, vinegar (like balsamic or red wine), a touch of honey, mustard, salt, and pepper. Drizzle the dressing over the salad just before serving and toss well to coat every leaf. This ensures your salad remains crisp and not soggy. Serve immediately as a light main dish or alongside your favorite entrée for a complete meal.", time: 10)
        
    ]
    
}


module suidouble_color::suidouble_color {
    use sui::tx_context::{Self, sender, TxContext};
    use std::string::{Self, utf8, String};
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use std::vector::{Self, append, insert};

    use sui::event::emit;
    
    // The creator bundle: these two packages often go together.
    use sui::package;
    use sui::display;

    /// Text size overflow.
    const EInvalidColor: u64 = 0;

    // ======== Events =========

    /// Event. When a new color minted
    struct ColorCreated has copy, drop { id: ID, r: u8, g: u8, b: u8 }

    /// The Hero - an outstanding collection of digital art.
    struct Color has key, store {
        id: UID,
        name: String,
        r: u8,
        g: u8,
        b: u8,
        img_url: String,
    }

    /// One-Time-Witness for the module.
    struct SUIDOUBLE_COLOR has drop {}

    /// In the module initializer we claim the `Publisher` object
    /// to then create a `Display`. The `Display` is initialized with
    /// a set of fields (but can be modified later) and published via
    /// the `update_version` call.
    ///
    /// Keys and values are set in the initializer but could also be
    /// set after publishing if a `Publisher` object was created.
    fun init(otw: SUIDOUBLE_COLOR, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            utf8(b"{name}"),
            // For `link` we can build a URL using an `id` property
            utf8(b"https://suidouble-color.herokuapp.com/color/{id}"),
            utf8(b"{img_url}"),
            // Description is static for all `Color` objects.
            utf8(b"What a nice color. Isn't it?"),
            // Project URL is usually static
            utf8(b"https://suidouble-color.herokuapp.com/"),
            // Creator field can be any
            utf8(b"Jeka")
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `Color` type.
        let display = display::new_with_fields<Color>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }

    /// Anyone can mint their `Color`!
    public entry fun mint(name: String, r: u8, g: u8, b: u8, ctx: &mut TxContext) {
        assert!(r >= 0 && r <= 255, EInvalidColor);
        assert!(g >= 0 && g <= 255, EInvalidColor);
        assert!(b >= 0 && b <= 255, EInvalidColor);

        let id = object::new(ctx);

        emit(ColorCreated { id: object::uid_to_inner(&id), r, g, b,  });

        // constructing the smallest (1x1) GIF with the color of RGB
        let gif_start = vector<u8>[71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 1, 0];
        let gif_end = vector<u8>[0, 0, 0, 33, 249, 4, 1, 10, 0, 1, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 2, 68, 1, 0, 59];
            
        insert(&mut gif_start, r, 13);  // appending R
        insert(&mut gif_start, g, 14);   // appending G
        insert(&mut gif_start, b, 15); // appending B
        append(&mut gif_start, gif_end);

        let img_url = encode(&gif_start);

        let base_prefix = b"data:image/gif;base64,";
        let as_string = utf8(base_prefix);
        string::append(&mut as_string, utf8(img_url));

        // 
        let color = Color { id, name, img_url: as_string, r: r, g: g, b: b };

        transfer::transfer(color, tx_context::sender(ctx));
    }

    // thanks to: https://github.com/movefuns/movefuns/blob/dd1f4443c6bf0bc761b27e28fb6ba00f10636840/stdlib/sources/base64.move#L2
    const TABLE: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    public fun encode(str: &vector<u8>): vector<u8> {
        if (vector::is_empty(str)) {
            return vector::empty<u8>()
        };
        let size = vector::length(str);
        let eq: u8 = 61;
        let res = vector::empty<u8>();

        let m = 0 ;
        while (m < size ) {
            vector::push_back(&mut res, *vector::borrow(&TABLE, (((*vector::borrow(str, m) & 0xfc) >> 2) as u64)));
            if ( m + 3 >= size) {
                if ( size % 3 == 1) {
                    vector::push_back(&mut res, *vector::borrow(&TABLE, (((*vector::borrow(str, m) & 0x03) << 4) as u64)));
                    vector::push_back(&mut res, eq);
                    vector::push_back(&mut res, eq);
                }else if (size % 3 == 2) {
                    vector::push_back(&mut res, *vector::borrow(&TABLE, ((((*vector::borrow(str, m) & 0x03) << 4) + ((*vector::borrow(str, m + 1) & 0xf0) >> 4)) as u64)));
                    vector::push_back(&mut res, *vector::borrow(&TABLE, (((*vector::borrow(str, m + 1) & 0x0f) << 2) as u64)));
                    vector::push_back(&mut res, eq);
                }else {
                    vector::push_back(&mut res, *vector::borrow(&TABLE, ((((*vector::borrow(str, m) & 0x03) << 4) + ((*vector::borrow(str, m + 1) & 0xf0) >> 4)) as u64)));
                    vector::push_back(&mut res, *vector::borrow(&TABLE, ((((*vector::borrow(str, m + 1) & 0x0f) << 2) + ((*vector::borrow(str, m + 2) & 0xc0) >> 6)) as u64)));
                    vector::push_back(&mut res, *vector::borrow(&TABLE, ((*vector::borrow(str, m + 2) & 0x3f) as u64)));
                };
            }else {
                vector::push_back(&mut res, *vector::borrow(&TABLE, ((((*vector::borrow(str, m) & 0x03) << 4) + ((*vector::borrow(str, m + 1) & 0xf0) >> 4)) as u64)));
                vector::push_back(&mut res, *vector::borrow(&TABLE, ((((*vector::borrow(str, m + 1) & 0x0f) << 2) + ((*vector::borrow(str, m + 2) & 0xc0) >> 6)) as u64)));
                vector::push_back(&mut res, *vector::borrow(&TABLE, ((*vector::borrow(str, m + 2) & 0x3f) as u64)));
            };
            m = m + 3;
        };

        return res
    }
}
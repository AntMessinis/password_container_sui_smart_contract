module password_container::password_container{
    use sui::object::{Self, Info};
    use sui::utf8::{Self, String};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    
    struct Password has key, store {
        info: Info,
        password: String,
    }

    // Wrapper for the Password struct
    struct PasswordContainer has key {
        info: Info,
        password: Password,
        owner: address
    }

    const ENotYourPassword: u64 = 204;

    // Creates a Password wraps it in a PasswordContainer and transfers it to owner address
    public fun create_password(pass: vector<u8>, ctx: &mut TxContext){
        let password = Password {
            info: object::new(ctx),
            password: utf8::string_unsafe(pass),
        };

        let container = store_password(password, ctx);
        transfer::transfer(container, tx_context::sender(ctx))
    }

    // If you are the owner of this container you can unwrap it and get the password
    public fun unpackPassword(container: PasswordContainer, ctx: &mut TxContext){
        assert!(container.owner == tx_context::sender(ctx), ENotYourPassword);
        let PasswordContainer {
            info: container_id,
            password,
            owner: _
        } = container;
        object::delete(container_id);
        transfer::transfer(password, tx_context::sender(ctx))
    }

    // Wraps the password in a container and returns the container
    fun store_password(password: Password, ctx: &mut TxContext) : PasswordContainer {
        PasswordContainer {
            info: object::new(ctx),
            password,
            owner: tx_context::sender(ctx)
        }
    }
}
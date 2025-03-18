import React from "react";
import {Link} from "react-router";

const Header = () => {
    return (
      <div className="flex flex-row justify-between align-middle
                      w-full h-auto py-6 px-12
                      bg-ultra-violet ">
          <Link to="/" className="text-4xl text-light-gray font-bold inline">
              AtlasMaker
          </Link>
          <div className="flex flex-row gap-7">
              <button>theme</button>
              <button>lang</button>
              <Link to="/" className="bg-timberwolf rounded-full">
                  <img src="/icons/user.png" alt="user icon" className="w-11 h-11"/>
              </Link>

          </div>
      </div>
    );
}

export default Header;
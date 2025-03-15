import React from "react";
import {Link} from "react-router";

const Header = () => {
    return (
      <div className="flex flex-row justify-between align-middle
                      w-full h-20 py-6 px-12
                      bg-ultra-violet ">
          <Link to="/" className="text-4xl text-light-gray font-bold inline">
              AtlasMaker
          </Link>
          <div className=" gap-7">
              <button>theme</button>
              <button>lang</button>
              <Link to="/" className="bg-timberwolf rounded-full">
                  <img src="../../assets/images/icons/user.svg" alt="user icon"/>
              </Link>
          </div>
      </div>
    );
}

export default Header;
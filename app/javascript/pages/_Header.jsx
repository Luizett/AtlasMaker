import React from "react";
import {Link} from "react-router";
import {useSelector} from "react-redux";

const Header = () => {
    const {avatar} = useSelector(state => state.user);
    return (
      <div className="flex flex-row justify-between align-middle
                      w-full h-auto
                      py-4 sm:py-6 px-6 sm:px-12
                      bg-ultra-violet ">
          <Link to="/" className="text-xl sm:text-4xl text-light-gray font-bold inline font-unbounded">
              AtlasMaker
          </Link>
          <div className="flex flex-row gap-4 sm:gap-7">
              <Link to="/user" className="bg-timberwolf rounded-full aspect-square overflow-hidden w-8 h-8 sm:w-11 sm:h-11">
                  <img src={avatar? avatar : "/icons/user.png"} alt="user icon" width={44} height={44} className="  object-fill"/>
              </Link>
          </div>
      </div>
    );
}

export default Header;